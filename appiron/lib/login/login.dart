import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_account.dart';
import 'forgot.dart';
import 'Gender.dart';
import 'load.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _currentLocale = Locale('en');

  void _changeLanguage(String languageCode) {
    setState(() {
      _currentLocale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _currentLocale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(),
      ),
      home: MainPage(
        currentLocale: _currentLocale, // ส่ง currentLocale ไปยัง MainPage
        changeLanguage: _changeLanguage,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final Locale currentLocale; // รับ currentLocale
  final Function(String) changeLanguage;

  MainPage({required this.currentLocale, required this.changeLanguage});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

          bool isFirstLogin = data != null && data.containsKey('isFirstLogin')
              ? data['isFirstLogin']
              : true;

          if (isFirstLogin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GenderSelectionScreen(),
              ),
            );

            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'isFirstLogin': false});
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoadingScreen(),
              ),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user found for that email.')),
          );
          break;
        case 'wrong-password':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wrong password provided.')),
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
          break;
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in canceled.')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GenderSelectionScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed.')),
        );
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _loginWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        await FirebaseAuth.instance.signInWithCredential(credential);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GenderSelectionScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${result.message}')),
        );
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Color.fromARGB(255, 236, 230, 230),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.1,
              vertical: screenHeight * 0.03,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => widget.changeLanguage('en'),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: widget.currentLocale.languageCode == 'en'
                                  ? Colors.red
                                  : Colors.transparent,
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(20)),
                            ),
                            child: Text(
                              'EN',
                              style: GoogleFonts.kanit(
                                fontSize: screenWidth * 0.05,
                                color: widget.currentLocale.languageCode == 'en'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => widget.changeLanguage('th'),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: widget.currentLocale.languageCode == 'th'
                                  ? Colors.red
                                  : Colors.transparent,
                              borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(20)),
                            ),
                            child: Text(
                              'TH',
                              style: GoogleFonts.kanit(
                                fontSize: screenWidth * 0.05,
                                color: widget.currentLocale.languageCode == 'th'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.14),
                Text(
                  'IRON BODY',
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
                SizedBox(height: screenHeight * 0.02),
                Container(
                  width: screenWidth * 0.7,
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(20.0), // Reduced corner radius
                    color: Color.fromARGB(255, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: S.of(context)!.email,
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 179, 179, 179),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Reduced corner radius
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Reduced corner radius
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                      prefixIcon: Icon(Icons.email, color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Container(
                  width: screenWidth * 0.7,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(20.0), // Reduced corner radius
                    color: Color.fromARGB(255, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: S.of(context)!.password,
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 179, 179, 179),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Reduced corner radius
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Reduced corner radius
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Reduced corner radius
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                      prefixIcon: Icon(Icons.lock, color: Colors.black),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateAccountPage(
                              currentLocale:
                                  widget.currentLocale, // ส่ง currentLocale
                              changeLanguage:
                                  widget.changeLanguage, // ส่ง changeLanguage
                            ),
                          ),
                        );
                      },
                      child: Text(
                        S.of(context)!.createAccount,
                        style: GoogleFonts.kanit(
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        S.of(context)!.forgotPassword,
                        style: GoogleFonts.kanit(
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),
                Container(
                  width: 130,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () => _login(context),
                    child: Center(
                      child: Text(
                        S.of(context)!.login,
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 202, 5, 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      elevation: 10,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.08),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: screenWidth * 0.05),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _signInWithGoogle(context),
                      child: Image.asset(
                        'images/google.png',
                        width: screenWidth * 0.1,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    Text(
                      S.of(context)!.or,
                      style: GoogleFonts.kanit(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    GestureDetector(
                      onTap: () => _loginWithFacebook(context),
                      child: Image.asset(
                        'images/facebook.png',
                        width: screenWidth * 0.1,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
