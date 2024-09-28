import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TypingText extends StatefulWidget {
  final String message;
  final TextStyle textStyle;
  final VoidCallback onFinished;

  TypingText({
    required this.message,
    required this.textStyle,
    required this.onFinished,
  });

  @override
  _TypingTextState createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String _displayedText = '';
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    while (_charIndex < widget.message.length) {
      await Future.delayed(Duration(milliseconds: 50));
      setState(() {
        _displayedText += widget.message[_charIndex];
        _charIndex++;
      });
    }
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.textStyle,
    );
  }
}



class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final String apiKey = dotenv.env['API_KEY'] ?? '';
  final ScrollController _scrollController = ScrollController();
  int _lastAnimatedIndex = -1;

  Future<void> _getGPTResponse(String userInput) async {
    final url = Uri.parse('http://localhost:3000/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [{'role': 'user', 'content': userInput}],
      'max_tokens': 1000,
      'stream': true,
    });

    final client = http.Client();
    try {
      final request = http.Request('POST', url);
      request.headers.addAll(headers);
      request.body = body;

      final response = await client.send(request);
      
      if (response.statusCode == 200) {
        final Stream<String> stream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        String currentSentence = '';
        List<String> sentences = [];

        await for (var line in stream) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;
            
            try {
              final jsonData = jsonDecode(data);
              final content = jsonData['choices'][0]['delta']['content'];
              if (content != null) {
                currentSentence += content;
                
                if (content.contains('.') || content.contains('!') || content.contains('?')) {
                  sentences.add(currentSentence.trim());
                  currentSentence = '';
                  _scrollToBottom();
                }
              }
            } catch (e) {
              print('Error parsing JSON: $e');
            }
          }
        }
        
        // 마지막 문장 처리
        if (currentSentence.isNotEmpty) {
          sentences.add(currentSentence.trim());
        }

        // 문장을 순차적으로 표시
        for (var sentence in sentences) {
          setState(() {
            messages.add({
              'message': sentence,
              'sender': 'bot',
              'isAnimated': false,
            });
          });
          _scrollToBottom();
          // 각 문장이 완전히 타이핑될 때까지 기다림
          await Future.delayed(Duration(milliseconds: 50 * sentence.length + 500));
        }
      } else {
        setState(() {
          messages.add({
            'message': '응답 실패: ${response.statusCode}',
            'sender': 'bot',
            'isAnimated': false,
          });
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        messages.add({
          'message': '오류 발생: $e',
          'sender': 'bot',
          'isAnimated': false,
        });
      });
    } finally {
      client.close();
    }
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    String userInput = _controller.text;
    setState(() {
      messages.add({
        'message': userInput,
        'sender': 'user',
        'isAnimated': false,
      });
    });

    _controller.clear();
    _scrollToBottom();
    await _getGPTResponse(userInput);

    _focusNode.requestFocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    final isUser = message['sender'] == 'user';
    final bubbleColor = isUser ? Colors.blue[100] : Colors.green[100];
    final textColor = isUser ? Colors.black : Colors.black87;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: isUser || message['isAnimated'] == true
            ? Text(
                message['message'],
                style: TextStyle(color: textColor),
              )
            : TypingText(
                message: message['message'],
                textStyle: TextStyle(color: textColor),
                onFinished: () {
                  setState(() {
                    message['isAnimated'] = true;
                  });
                },
              ),
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('안녕 봇'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message, index);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(HelloBot());
}

class HelloBot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme : ThemeData(
            primarySwatch : Colors.red,
            fontFamily : 'GmarketSansTTFBold'
        ),
      home: ChatScreen(),
    );
  }
}