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
    );
  }
}

class Calorie extends StatefulWidget implements PreferredSizeWidget {
  const Calorie({Key? key}) : super(key: key);

  @override
  _CalorieState createState() => _CalorieState();

  @override
  Size get preferredSize => Size.fromHeight(120.0);
}

class _CalorieState extends State<Calorie> {
  Stream<DocumentSnapshot<Map<String, dynamic>>> _nutritionStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots();
    }
    return Stream.empty(); // หากไม่มีผู้ใช้ ให้คืนค่าเป็นสตรีมว่าง
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 221, 8, 8), // พื้นหลังสีแดง
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40.0),
            bottomRight: Radius.circular(40.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _nutritionStream(),
            builder: (context, snapshot) {
              // คงพื้นหลังไว้ ไม่โหลดใหม่ แต่แค่แสดงตัวเลขใหม่เมื่อมีข้อมูล
              final nutritionData = snapshot.data?.data() ?? {};

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
                      ),
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: Color.fromARGB(255, 0, 0, 0),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                // แสดง BMR เป็นจำนวนเต็ม
                                text:
                                    '${double.parse((nutritionData['bmr'] ?? '0').toString()).toInt()}',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 27, 234, 79),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              TextSpan(
                                text: '\n' + S.of(context)!.kcal,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNutritionText(S.of(context)!.ca,
                          nutritionData['carbohydrates'] ?? '0'),
                      SizedBox(height: 8.0),
                      _buildNutritionText(
                          S.of(context)!.po, nutritionData['protein'] ?? '0'),
                      SizedBox(height: 8.0),
                      _buildNutritionText(
                          S.of(context)!.fat, nutritionData['fat'] ?? '0'),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันแสดงผลโภชนาการ
  Widget _buildNutritionText(String label, dynamic value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          // แสดงค่าเป็นจำนวนเต็มสำหรับค่า Carbohydrate, Protein และ Fat
          TextSpan(
            text: '${double.parse(value.toString()).toInt().toString()} ',
            style: TextStyle(
              color: Color.fromARGB(255, 27, 234, 79),
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          TextSpan(
            text: S.of(context)!.g,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
