import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      home: PasswordScreen(),
    );
  }
}

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void _updatePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      _showSnackbar('New password and confirm password do not match');
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _showSnackbar('No user is logged in');
        return;
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);

      await _firestore.collection('users').doc(user.uid).update({
        'password': newPassword,
      });

      _showSnackbar('Password updated successfully');

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'wrong-password') {
          _showSnackbar('Incorrect old password');
        } else {
          _showSnackbar('Failed to update password: ${e.message}');
        }
      } else {
        _showSnackbar('An unknown error occurred');
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        title: Text(
          S.of(context)!.password,
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: const Color.fromARGB(255, 255, 255, 255)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context)!.password,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[300],
              ),
            ),
            SizedBox(height: 16),
            Text(
              S.of(context)!.npassword,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[300],
              ),
            ),
            SizedBox(height: 16),
            Text(
              S.of(context)!.confirmpassword,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[300],
              ),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 202, 5, 5),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  S.of(context)!.save,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
