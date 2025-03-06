import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot.dart'; // เพิ่มการนำเข้าไฟล์ main.dart

class EnterOTPPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 236, 230, 230),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, -5),
                  child: Text(
                    'OTP',
                    style: GoogleFonts.kanit(
                      fontSize: 80,
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
                ),
                SizedBox(height: 50),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: screenWidth * 0.7,
                    margin: EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.0),
                      color: Color.fromARGB(255, 255, 255, 255),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter OTP',
                            hintStyle: GoogleFonts.kanit(
                              color: const Color.fromARGB(255, 179, 179, 179),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              borderSide: BorderSide(
                                color: Colors.white, // ขอบเส้นสีขาว
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              borderSide: BorderSide(
                                color: Colors.white, // ขอบเส้นสีขาว
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              borderSide: BorderSide(
                                color: Colors.white, // ขอบเส้นสีขาว
                                width: 1.5,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 50.0,
                              vertical: 15.0,
                            ),
                          ),
                          style: GoogleFonts.kanit(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 110),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ForgotPasswordPage()), // นำไปยังหน้า Main
                          );
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 202, 5, 5),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 5.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(4.0, 4.0),
                              ),
                            ],
                          ),
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.kanit(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // นำไปยังหน้าก่อนหน้า
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 202, 5, 5),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 5.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(4.0, 4.0),
                              ),
                            ],
                          ),
                          child: Text(
                            'Back',
                            style: GoogleFonts.kanit(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
