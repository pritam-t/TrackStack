import 'package:flutter/material.dart';
import 'package:learn_phase/pages/daily_page.dart';
import 'TODO/todopage.dart';

void main()
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue, // for consistency
        scaffoldBackgroundColor: Color.fromRGBO(199, 220, 225, 1.0),
        fontFamily: 'Merri',

      ),
      debugShowCheckedModeBanner: false,
      home: DailyPages(),
    );
  }
}
