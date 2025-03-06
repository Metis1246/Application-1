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
      home: AccountScreen(),
    );
  }
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _usernameController.text = userDoc['username'] ?? '';
          _weightController.text = userDoc['weight'] ?? '';
          _heightController.text = userDoc['height'] ?? '';
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'username': _usernameController.text,
          'weight': _weightController.text,
          'height': _heightController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        title: Text(
          S.of(context)!.account,
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
              S.of(context)!.username,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _usernameController,
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
              S.of(context)!.weight,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[300],
                suffixText: S.of(context)!.kg,
              ),
            ),
            SizedBox(height: 16),
            Text(
              S.of(context)!.height,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[300],
                suffixText: S.of(context)!.cm,
              ),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _updateUserData,
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
