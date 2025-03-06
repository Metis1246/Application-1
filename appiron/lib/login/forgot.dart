import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'OTP.dart';
import 'enterotp.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final OTPService otpService = OTPService();
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
                    'FORGOT',
                    style: GoogleFonts.kanit(
                      fontSize: 55,
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
                Transform.translate(
                  offset: Offset(0, -25),
                  child: Text(
                    'PASSWORD',
                    style: GoogleFonts.kanit(
                      fontSize: 55,
                      color: Color.fromARGB(255, 202, 5, 5),
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(4.0, 4.0),
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
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: GoogleFonts.kanit(
                              color: const Color.fromARGB(255, 179, 179, 179),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              borderSide: BorderSide(
                                color: Colors.white,
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
                        Positioned(
                          left: 15,
                          top: 18,
                          child: Icon(
                            Icons.email,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            size: 20,
                          ),
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
                        onTap: () async {
                          String email = emailController.text;

                          if (email.isEmpty ||
                              !RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('กรุณากรอกอีเมลที่ถูกต้อง')),
                            );
                            return;
                          }

                          await otpService.sendOtp(email);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EnterOTPPage()),
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
                          Navigator.pop(context);
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
