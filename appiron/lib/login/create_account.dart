import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'package:google_fonts/google_fonts.dart';
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
      home: CreateAccountPage(
        currentLocale: Locale('en'),
        changeLanguage: (String langCode) {},
      ),
    );
  }
}

class CreateAccountPage extends StatefulWidget {
  final Locale currentLocale;
  final Function(String) changeLanguage;

  CreateAccountPage(
      {required this.currentLocale, required this.changeLanguage});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  String _errorMessage = '';
  bool _isProcessing = false;

  Future<void> _createAccount(BuildContext context) async {
    setState(() {
      _errorMessage = '';
      _isProcessing = true;
    });

    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
        _isProcessing = false;
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
        _isProcessing = false;
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: emailController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _errorMessage = 'The email address is already in use.';
          _isProcessing = false;
        });
        return;
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': emailController.text,
        'username': usernameController.text,
        'password': passwordController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(
            currentLocale: widget.currentLocale,
            changeLanguage: widget.changeLanguage,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          _errorMessage = 'The password provided is too weak.';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _errorMessage = 'The account already exists for that email.';
        });
      } else {
        setState(() {
          _errorMessage = 'An unexpected error occurred: ${e.message}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(255, 236, 230, 230),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  Column(
                    children: [
                      Text(
                        S.of(context)!.create,
                        style: GoogleFonts.kanit(
                          fontSize: screenWidth * 0.15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 202, 5, 5),
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        S.of(context)!.account,
                        style: GoogleFonts.kanit(
                          fontSize: screenWidth * 0.15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 202, 5, 5),
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildInputContainer(
                    controller: usernameController,
                    hintText: S.of(context)!.username,
                    icon: Icons.person,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildInputContainer(
                    controller: emailController,
                    hintText: S.of(context)!.email,
                    icon: Icons.email,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildInputContainer(
                    controller: passwordController,
                    hintText: S.of(context)!.password,
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildInputContainer(
                    controller: confirmPasswordController,
                    hintText: S.of(context)!.confirmpassword,
                    isPassword: true,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (_errorMessage.isNotEmpty)
                    _buildErrorMessage(_errorMessage),
                  SizedBox(height: screenHeight * 0.02),
                  _isProcessing
                      ? CircularProgressIndicator()
                      : InkWell(
                          onTap: () {
                            _createAccount(context);
                          },
                          child: Container(
                            width: screenWidth * 0.3,
                            height: screenHeight * 0.06,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 202, 5, 5),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              S.of(context)!.confirm,
                              style: GoogleFonts.kanit(
                                color: Colors.white,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: screenHeight * 0.03),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: screenWidth * 0.3,
                      height: screenHeight * 0.06,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 202, 5, 5),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        S.of(context)!.back,
                        style: GoogleFonts.kanit(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    bool isPassword = false,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: GoogleFonts.kanit(
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.kanit(
            color: Colors.black.withOpacity(0.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
          prefixIcon: icon != null ? Icon(icon, color: Colors.black) : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: _togglePasswordVisibility,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Text(
      message,
      style: TextStyle(color: Colors.red),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }
}
