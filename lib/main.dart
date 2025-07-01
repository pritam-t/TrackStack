import 'package:flutter/material.dart';
import 'package:learn_phase/pages/splash_screen.dart';

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
        scaffoldBackgroundColor: Color.fromRGBO(208, 243, 255, 1.0), //
        fontFamily: 'Merri',

      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
