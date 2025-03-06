import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  runApp(MyApp());
}

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
      home: RankScreen(),
    );
  }
}

class RankScreen extends StatefulWidget {
  @override
  _RankScreenState createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  List<AppUser> users = [];
  File? _profileImage; // เพิ่มฟิลด์สำหรับเก็บรูปโปรไฟล์
  AppUser? currentUser; // เก็บข้อมูลของผู้ใช้ที่ล็อกอิน

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // ดึงรูปจาก SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? imagePath = prefs.getString('profileImage');
      if (imagePath != null) {
        setState(() {
          _profileImage = File(imagePath); // เก็บเส้นทางของไฟล์รูปโปรไฟล์
        });
      }

      // ดึงข้อมูลผู้ใช้ทั้งหมดจาก Firestore
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<AppUser> loadedUsers = [];

      for (var doc in querySnapshot.docs) {
        String username = doc['username'] ?? 'Unknown User';
        int score = doc['rank'] ?? 0; // เปลี่ยนจาก rank เป็น score

        // สร้าง AppUser สำหรับแต่ละผู้ใช้
        AppUser user = AppUser(
          name: username,
          score: score,
          rank: 0, // กำหนดเป็น 0 ชั่วคราว
          profileImage:
              (doc.id == firebase_auth.FirebaseAuth.instance.currentUser?.uid)
                  ? _profileImage // รูปโปรไฟล์ผู้ใช้ที่ล็อกอิน
                  : null, // รูปโปรไฟล์ของผู้ใช้อื่น
        );

        if (doc.id == firebase_auth.FirebaseAuth.instance.currentUser?.uid) {
          currentUser = user; // เก็บข้อมูลของผู้ใช้ที่ล็อกอิน
        }

        loadedUsers.add(user);
      }

      // จัดเรียงผู้ใช้ตาม score จากมากไปน้อย
      loadedUsers.sort((a, b) => b.score.compareTo(a.score));

      // กำหนดค่า rank ให้กับแต่ละผู้ใช้ตามลำดับ
      for (int index = 0; index < loadedUsers.length; index++) {
        loadedUsers[index] = AppUser(
          name: loadedUsers[index].name,
          score: loadedUsers[index].score,
          rank: index + 1, // ตั้งค่า rank จาก 1
          profileImage: loadedUsers[index].profileImage ??
              File(
                  'images/${Random().nextInt(9) + 1}.png'), // ใช้รูปโปรไฟล์ที่สุ่ม
        );
      }

      setState(() {
        users = loadedUsers; // อัปเดต list ของผู้ใช้
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  int _getRankFromScore(int score) {
    if (score >= 200) {
      return 1; // Rank 1 for scores 200 and above
    } else if (score >= 100) {
      return 2; // Rank 2 for scores 100 to 199
    } else {
      return 11; // Rank 10 for scores less than 100
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              if (users.isNotEmpty) TopUserSection(user: users.first),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      users.length > 10 ? 10 : users.length, // แสดงแค่ 10 คนแรก
                  itemBuilder: (context, index) {
                    return UserRankTile(
                      user: users[index],
                      key: ValueKey(users[index].rank),
                    );
                  },
                ),
              ),
            ],
          ),
          // แสดงข้อมูลผู้ใช้ปัจจุบันด้านล่าง
          if (currentUser != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: currentUser?.profileImage != null
                          ? FileImage(currentUser!.profileImage!)
                          : AssetImage('images/person.png') as ImageProvider,
                      radius: 25,
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${S.of(context)!.r} : ${_getRankFromScore(currentUser!.score)}', // Display rank based on score
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${S.of(context)!.name} : ${currentUser!.name}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${S.of(context)!.score} : ${currentUser!.score}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TopEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, 34.0);
    path.lineTo(size.width, 34.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class TopUserSection extends StatelessWidget {
  final AppUser user;

  TopUserSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TopEdgeClipper(),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45.0),
          bottomRight: Radius.circular(45.0),
        ),
        child: Container(
          width: double.infinity,
          color: Color.fromARGB(255, 221, 8, 8),
          padding: EdgeInsets.all(70.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey,
                    backgroundImage: user.profileImage != null
                        ? FileImage(user.profileImage!)
                        : AssetImage('assets/images/person.png')
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 52,
                    child: FaIcon(
                      FontAwesomeIcons.crown,
                      size: 40,
                      color: Color.fromARGB(255, 236, 207, 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1),
              Text(
                user.name,
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 1),
              Text(
                user.score.toString(),
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserRankTile extends StatelessWidget {
  final AppUser user;

  UserRankTile({required this.user, required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      height: 75,
      child: Row(
        children: [
          Text(
            user.rank.toString(),
            style: TextStyle(
              fontSize: 24,
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 14),
          CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: user.profileImage != null
                ? FileImage(user.profileImage!)
                : AssetImage('assets/images/person.png') as ImageProvider,
            radius: 25,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              user.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            user.score.toString(),
            style: TextStyle(
              fontSize: 24,
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AppUser {
  final String name;
  final int score;
  final int rank;
  final File? profileImage;

  AppUser({
    required this.name,
    required this.score,
    required this.rank,
    this.profileImage,
  });
}
