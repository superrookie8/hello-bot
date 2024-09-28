import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:html' as html;

class AttendDiary extends StatefulWidget {
  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<AttendDiary> {
  DateTime selectedDate = DateTime.now();
  String selectedWeather = '맑음';
  String selectedPlace = '부산 사직실내체육관';
  String selectedCompanion = '나와 함께';
  String selectedResult = '승';
  String selectedSection = 'A';
  String selectedRow = '1';
  String selectedSeat = '1';
  dynamic _image;
  final TextEditingController _messageController = TextEditingController();

  // 날씨에 따른 아이콘 매핑
  final Map<String, IconData> weatherIcons = {
    '맑음': Icons.wb_sunny,
    '흐림': Icons.cloud,
    '비': Icons.umbrella,
    '눈': Icons.ac_unit,
    '번개': Icons.flash_on,
    '맑은밤': Icons.nightlight_round,
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (kIsWeb) {
          _image = html.File([bytes], pickedFile.name);
        } else {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('직관일지 작성'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: '날짜',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: DateFormat('yyyy-MM-dd').format(selectedDate),
                        items: [DateFormat('yyyy-MM-dd').format(selectedDate)].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onTap: () => _selectDate(context),
                        onChanged: (String? newValue) {
                          // 날짜 선택은 onChanged에서 처리하지 않음
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: '날씨',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: selectedWeather,
                        items: weatherIcons.keys.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(weatherIcons[value], size: 18),
                                SizedBox(width: 6),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedWeather = newValue!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: '승패',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: selectedResult,
                        items: ['승', '패'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedResult = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: '함께 본 사람',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: selectedCompanion,
                        items: ['나와 함께', '가족', '친구', '연인', '동료'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCompanion = newValue!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: '장소',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: selectedPlace,
                        items: [
                          '부산 사직실내체육관', '아산 이순신체육관', '용인 실내체육관',
                          '인천 도원체육관', '부천 체육관', '청주 체육관', '창원 실내체육관', '울산 동천체육관'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPlace = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: '구역',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: selectedSection,
                        items: ['A', 'B', 'C', 'D'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedSection = newValue!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: '열',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: selectedRow,
                        items: List.generate(20, (index) => (index + 1).toString()).map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRow = newValue!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: '좌석',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: selectedSeat,
                        items: List.generate(20, (index) => (index + 1).toString()).map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedSeat = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
            // 사진 업로드
            ElevatedButton(
              onPressed: _getImage,
              child: Text('사진 업로드'),
            ),
            SizedBox(height: 10),
            // 이미지 미리보기
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _image != null
                ? kIsWeb
                  ? AspectRatio(
                      aspectRatio: 16 / 9, // 기본 비율을 16:9로 설정, 필요에 따라 조정 가능
                      child: Image.network(
                        html.Url.createObjectUrlFromBlob(_image),
                        fit: BoxFit.contain,
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: 16 / 9, // 기본 비율을 16:9로 설정, 필요에 따라 조정 가능
                      child: Image.file(
                        _image,
                        fit: BoxFit.contain,
                      ),
                    )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        '선택된 이미지가 없습니다.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
            ),
            SizedBox(height: 20),
            // 메시지 입력
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: '메시지를 입력하세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 저장 로직 추가
                    print('저장됨');
                  },
                  child: Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

