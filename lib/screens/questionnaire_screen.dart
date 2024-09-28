import 'package:attend/screens/attend_diary.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '직관일지',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuestionnaireScreen(),
    );
  }
}

class QuestionnaireScreen extends StatefulWidget {
  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': '농구 좋아하세요?',
      'answers': ['예', '아니오'],
    },
    {
      'question': '좋아하는 리그는 무엇인가요?',
      'answers': ['WKBL', 'WNBA', 'KBL', 'NBA'],
    },
  ];

  int currentQuestionIndex = 0;
  List<String> userAnswers = [];

  void _submitAnswer(String selectedAnswer) {
    setState(() {
      userAnswers.add(selectedAnswer);
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        // 모든 질문에 답변했을 때 메인 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AttendDiary()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('직관일지 질문'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/soheecharacter.png', height: 200),
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                currentQuestion['question'],
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            ...currentQuestion['answers'].map<Widget>((answer) =>
             Container(
              width: 150,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _submitAnswer(answer),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical:10),
                  ),
                  child: Text(answer),
                ),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }
}
