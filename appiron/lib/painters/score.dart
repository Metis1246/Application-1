import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: ScorePage(),
    );
  }
}

class ScorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // เรียกฟังก์ชันเพื่อบันทึกคะแนนลง Firebase
    _saveScoreToFirebase(100);

    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).pop();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          S.of(context)!.score + (": 100"),
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 0, 0),
          ),
        ),
      ),
    );
  }

  void _saveScoreToFirebase(int score) async {
    try {
      User? user = FirebaseAuth
          .instance.currentUser; // ตรวจสอบว่าผู้ใช้เข้าสู่ระบบหรือไม่
      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(user.uid).update({
          'rank': score, // อัปเดตฟิลด์ rank ด้วยค่า score
        });
        print('Score updated successfully.');
      } else {
        print('User not logged in.');
      }
    } catch (e) {
      print('Failed to update score: $e');
    }
  }
}
