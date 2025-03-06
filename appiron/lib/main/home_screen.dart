import 'package:flutter/material.dart';
import 'calorie.dart';
import 'package:iron/pages/pages1.dart';
import 'package:iron/pages/pages3.dart';
import 'package:iron/pages/pages4.dart';
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
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Calorie(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBoxWithTextOutside(
                    Color.fromARGB(255, 0, 0, 0),
                    S.of(context)!.l,
                    () {
                      _navigateToPoseDetectorView(context);
                    },
                    hasImage: true,
                    imagePath: 'images/LEG.png',
                  ),
                  _buildBoxWithTextOutside(
                    const Color.fromARGB(255, 0, 0, 0),
                    S.of(context)!.a,
                    () {
                      _navigateToPoseDetectorView2(context);
                    },
                    hasImage: true,
                    imagePath: 'images/ABDOMEN.png',
                  ),
                  _buildBoxWithTextOutside(
                    const Color.fromARGB(255, 0, 0, 0),
                    S.of(context)!.b,
                    () {
                      _navigateToPoseDetectorView3(context);
                    },
                    hasImage: true,
                    imagePath: 'images/BEHIND.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxWithTextOutside(Color color, String label, VoidCallback onTap,
      {bool hasImage = false, String? imagePath}) {
    return Padding(
      padding: const EdgeInsets.only(top: 17.0),
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 300,
                height: 270,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Positioned(
                top: 20,
                left: 15,
                child: Container(
                  width: 270,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: hasImage && imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 20,
                top: 140,
                left: 5,
                child: Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPoseDetectorView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Pages1Screen()),
    );
  }

  void _navigateToPoseDetectorView2(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Pages3Screen()),
    );
  }

  void _navigateToPoseDetectorView3(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Pages4Screen()),
    );
  }
}
