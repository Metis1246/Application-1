import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron/main/main.dart';
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

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      await Future.delayed(Duration(seconds: 3));

      // ดึงค่า BMR และ Weight จาก Firebase
      Map<String, dynamic> userData = await _fetchUserDataFromFirestore();
      double bmr = userData['bmr'];
      double weight = userData['weight'];

      print(
          'Fetched BMR: $bmr, Weight: $weight'); // ตรวจสอบว่าดึงข้อมูลได้ถูกต้อง

      // คำนวณโปรตีน = weight * 1.6
      double proteinGrams = weight * 1.6;

      // บันทึกโปรตีนลงบน Firebase
      await _saveDataToFirestore('protein', proteinGrams);

      // คำนวณ caloriesA = protein * 4
      double caloriesA = proteinGrams * 4;

      // บันทึก caloriesA ลงบน Firebase
      await _saveDataToFirestore('caloriesA', caloriesA);

      // คำนวณ caloriesB = (bmr / 100) * 20
      double caloriesB = (bmr / 100) * 20;

      // บันทึก caloriesB ลงบน Firebase
      await _saveDataToFirestore('caloriesB', caloriesB);

      // คำนวณ fat = caloriesB / 9
      double fatGrams = caloriesB / 9;

      // บันทึก fat ลงบน Firebase
      await _saveDataToFirestore('fat', fatGrams);

      // คำนวณ caloriesC = caloriesA + caloriesB
      double caloriesC = caloriesA + caloriesB;

      // บันทึก caloriesC ลงบน Firebase
      await _saveDataToFirestore('caloriesC', caloriesC);

      // คำนวณ caloriesD = bmr - caloriesC
      double caloriesD = bmr - caloriesC;

      // บันทึก caloriesD ลงบน Firebase
      await _saveDataToFirestore('caloriesD', caloriesD);

      // คำนวณ carbohydrates = caloriesD / 4
      double carbGrams = caloriesD / 4;

      // บันทึก carbohydrates ลงบน Firebase
      await _saveDataToFirestore('carbohydrates', carbGrams);

      print('All data saved successfully'); // ตรวจสอบว่าข้อมูลถูกบันทึกสำเร็จ

      // เปลี่ยนหน้าไปยังหน้า Home หลังจากคำนวณเสร็จ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } catch (e) {
      print(
          'Error during navigation or data processing: $e'); // ตรวจสอบข้อผิดพลาดที่เกิดขึ้น
    }
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จาก Firebase (bmr และ weight)
  // ฟังก์ชันดึงข้อมูลผู้ใช้จาก Firebase (bmr และ weight)
  // ฟังก์ชันดึงข้อมูลผู้ใช้จาก Firebase (bmr และ weight)
  Future<Map<String, dynamic>> _fetchUserDataFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // ตรวจสอบและแปลงจาก String เป็น double หากจำเป็น
        double bmr = data['bmr'] is String
            ? double.tryParse(data['bmr']) ?? 0.0
            : data['bmr'] is int
                ? (data['bmr'] as int).toDouble()
                : data['bmr'];

        double weight = data['weight'] is String
            ? double.tryParse(data['weight']) ?? 0.0
            : data['weight'] is int
                ? (data['weight'] as int).toDouble()
                : data['weight'];

        return {'bmr': bmr, 'weight': weight};
      }
    }
    return {'bmr': 0.0, 'weight': 0.0};
  }

  Future<void> _saveDataToFirestore(String field, double value) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      Map<String, dynamic> nutritionInfo = {
        field: value,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(nutritionInfo, SetOptions(merge: true));

      print('$field ถูกบันทึกเรียบร้อยแล้ว: $value');
    } else {
      print('ไม่พบข้อมูลผู้ใช้');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 202, 5, 5),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: Column(
            children: [
              Spacer(flex: 15),
              SpinKitCircle(
                color: Colors.white,
                size: 80.0,
              ),
              SizedBox(height: 20),
              Text(
                S.of(context)!.loading,
                style: GoogleFonts.kanit(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
