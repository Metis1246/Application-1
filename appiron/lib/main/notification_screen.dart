import 'package:flutter/material.dart';
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
      home: NotificationsScreen(notificationText: ''),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key, required this.notificationText})
      : super(key: key);

  final String notificationText;

  String _getNotificationText(BuildContext context) {
    DateTime now = DateTime.now();
    String notificationText;

    switch (now.weekday) {
      case 1:
        notificationText = S.of(context)!.l;
        break;
      case 2:
        notificationText = S.of(context)!.a;
        break;
      case 3:
        notificationText = S.of(context)!.b;
        break;
      case 4:
        notificationText = S.of(context)!.l;
        break;
      case 5:
        notificationText = S.of(context)!.a;
        break;
      case 6:
        notificationText = S.of(context)!.b;
        break;
      case 7:
        notificationText = S.of(context)!.c;
        break;
      default:
        notificationText = 'No workout';
    }

    return notificationText;
  }

  @override
  Widget build(BuildContext context) {
    String notificationText = _getNotificationText(context);

    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 255, 255, 255),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.circular(20),
                ),
                width: double.infinity,
                height: 120,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: S.of(context)!.today,
                            style: TextStyle(
                              color: Color.fromARGB(255, 30, 255, 0),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: notificationText,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 0, 0),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
}
