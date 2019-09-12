import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:promethean_2k19/splashScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay: true,
      title: "Promethean2K19",
      home: Scaffold(body: TestTing()),
    );
  }
}


class TestTing extends StatefulWidget {
  @override
  _TestTingState createState() => _TestTingState();
}

class _TestTingState extends State<TestTing> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
  _firebaseMessaging.configure(
       onMessage: (Map<String, dynamic> message) async {
         print("onMessage: ");

        },
       onLaunch: (Map<String, dynamic> message) async {
         print("onLaunch: ");
       },
       onResume: (Map<String, dynamic> message) async {
         print("onResume: ");
       },
     );
  }

  

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}
