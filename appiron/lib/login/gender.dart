import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'List.dart';
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
      home: GenderSelectionScreen(),
    );
  }
}

class GenderSelectionScreen extends StatefulWidget {
  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  bool isWomanSelected = false;
  bool isMenSelected = false;

  void _saveGenderToFirestore(String userId, String gender) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'gender': gender,
      }, SetOptions(merge: true));
      print('Gender saved successfully');
    } catch (e) {
      print('Failed to save gender: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            color: Color.fromARGB(255, 236, 230, 230),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1,
                  vertical: screenHeight * 0.01,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context)!.gender,
                      style: GoogleFonts.kanit(
                        fontSize: screenWidth * 0.15,
                        color: Color.fromARGB(255, 202, 5, 5),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(6.0, 6.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.06,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isWomanSelected = true;
                          isMenSelected = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: screenWidth * 0.44,
                        height: screenWidth * 0.44,
                        decoration: BoxDecoration(
                          color: isWomanSelected
                              ? Color.fromARGB(255, 202, 5, 5)
                              : Color.fromARGB(255, 169, 169, 169),
                          borderRadius:
                              BorderRadius.circular(16), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: isWomanSelected
                                  ? Offset(0, 0)
                                  : Offset(6.0, 6.0), // Shadow position
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.female,
                              color: Colors.pinkAccent,
                              size: screenWidth * 0.35,
                            ),
                            Text(
                              S.of(context)!.women,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ), // Space between the boxes
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMenSelected = true;
                          isWomanSelected = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: screenWidth * 0.44,
                        height: screenWidth * 0.44,
                        decoration: BoxDecoration(
                          color: isMenSelected
                              ? Color.fromARGB(255, 202, 5, 5)
                              : Color.fromARGB(255, 169, 169, 169),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: isMenSelected
                                  ? Offset(0, 0)
                                  : Offset(6.0, 6.0), // Shadow position
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.male,
                              color: Colors.lightBlue,
                              size: screenWidth * 0.35,
                            ),
                            Text(
                              S.of(context)!.men,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.02,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: GestureDetector(
              onTap: () async {
                if (isWomanSelected || isMenSelected) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    String userId = user.uid;
                    String gender = isWomanSelected ? 'Woman' : 'Men';

                    // บันทึกเพศลง Firestore
                    _saveGenderToFirestore(userId, gender);

                    // นำทางไปยังหน้าจอถัดไป
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListScreen()),
                    );
                  } else {
                    // หากไม่มีผู้ใช้ล็อกอิน แสดงข้อความหรือทำการอื่น
                    print('No user is logged in');
                  }
                }
              },
              child: Container(
                height: screenHeight * 0.08,
                decoration: BoxDecoration(
                  color: (isWomanSelected || isMenSelected)
                      ? Color.fromARGB(255, 202, 5, 5)
                      : Color.fromARGB(255, 169, 169, 169),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(6.0, 6.0),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    S.of(context)!.next,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
