import 'package:flutter/material.dart';
import 'screens/questionnaire_screen.dart';
import 'screens/attend_diary.dart';
import 'screens/hellobot.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "직관일지",
        theme: ThemeData(
          primarySwatch: Colors.red,
          fontFamily: 'GmarketSansTTF'
        ),
        // home: QuestionnaireScreen(),
        home: HelloBot(),
        routes: {
          // '/questionnaire': (context) => QuestionnaireScreen(),
          // '/main': (context) => AttendDiary()
          'hellobot': (context) => HelloBot()
        });
  }
}
