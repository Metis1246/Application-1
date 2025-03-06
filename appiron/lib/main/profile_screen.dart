import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iron/password/password.dart';
import 'package:iron/account/account.dart';

import 'package:iron/login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
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
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String bmr = '0';
  String bmi = '0';
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImage');
    if (imagePath != null) {
      setState(() {
        _image = File(imagePath);
      });
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? 'Unknown User';
          bmr = userDoc['bmr']?.toString() ?? '0';
          bmi = userDoc['bmi']?.toString() ?? '0';
        });
      } else {
        setState(() {
          username = 'User data not found';
          bmr = '0';
          bmi = '0';
        });
      }
    } else {
      setState(() {
        username = 'No user logged in';
        bmr = '0';
        bmi = '0';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery); // เปิดแกลเลอรี่ให้เลือกภาพ

    if (pickedFile != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage',
          pickedFile.path); // บันทึกเส้นทางของรูปภาพใน SharedPreferences

      setState(() {
        _image = File(pickedFile.path); // อัพเดตภาพในวงกลม
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: _pickImage, // เปิดหน้าต่างเลือกรูปภาพ
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[400],
                  backgroundImage: _image != null
                      ? FileImage(_image!) // ถ้าเลือกรูปแล้วให้แสดงรูปที่เลือก
                      : AssetImage('images/person.png')
                          as ImageProvider, // ถ้ายังไม่มีให้แสดงรูป default
                ),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                username,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoCard(
                    S.of(context)!.t, '', Icons.local_fire_department),
                _buildInfoCard(S.of(context)!.kcal, bmr),
                _buildInfoCard(S.of(context)!.bmi, bmi)
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsCard(
                      icon: Icons.person,
                      title: S.of(context)!.account,
                      trailing:
                          Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountScreen()),
                        );
                      },
                    ),
                    SettingsCard(
                      icon: Icons.lock,
                      title: S.of(context)!.password,
                      trailing:
                          Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PasswordScreen()),
                        );
                      },
                    ),
                    SettingsCard(
                      icon: Icons.logout,
                      title: S.of(context)!.lo,
                      trailing:
                          Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainPage(
                              currentLocale:
                                  Locale('en'), // หรือค่าอื่นๆ ที่ต้องการ
                              changeLanguage: (languageCode) {
                                // ฟังก์ชันที่ใช้เปลี่ยนภาษา
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, [IconData? icon]) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: Color.fromARGB(255, 202, 5, 5),
                  ),
                  SizedBox(width: 10),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ] else ...[
              Text(
                value,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  const SettingsCard({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 0, 0, 0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
