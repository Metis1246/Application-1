import 'package:flutter/material.dart';
import 'package:iron/views/pose_detection_pushup_view.dart';
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
      home: Pages2Screen(),
    );
  }
}

class Pages2Screen extends StatefulWidget {
  const Pages2Screen({Key? key}) : super(key: key);

  @override
  _Pages2ScreenState createState() => _Pages2ScreenState();
}

class _Pages2ScreenState extends State<Pages2Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        title: Text(
          '',
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
      body: Column(
        children: [
          Spacer(flex: 1),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 60),
          // รายละเอียดใต้กล่อง
          Text(
            S.of(context)!.text1,
            style: TextStyle(fontSize: 19, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          Spacer(flex: 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PoseDetectorView1()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Center(
                child: Text(
                  S.of(context)!.play,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          Spacer(flex: 1),
        ],
      ),
    );
  }
}
