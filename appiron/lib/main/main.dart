import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'rank.dart';
import 'dart:developer';
import 'package:iron/bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: MyHomePage(),
      routes: {
        '/home': (context) => MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _pageController = PageController(initialPage: 2);
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 2);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      RankScreen(),
      CalendarScreen(),
      HomeScreen(),
      NotificationsScreen(
        notificationText: '',
      ),
      ProfileScreen(),
    ];

    final List<BottomBarItem> bottomBarItems = [
      BottomBarItem(
        inActiveItem: Icon(Icons.bar_chart, color: Colors.white),
        activeItem: Icon(Icons.bar_chart, color: Colors.white),
        itemLabel: S.of(context)!.rank,
      ),
      BottomBarItem(
        inActiveItem: Icon(Icons.calendar_today, color: Colors.white),
        activeItem: Icon(Icons.calendar_today, color: Colors.white),
        itemLabel: S.of(context)!.calendar,
      ),
      BottomBarItem(
        inActiveItem: Icon(Icons.home, color: Colors.white),
        activeItem: Icon(Icons.home, color: Colors.white),
        itemLabel: S.of(context)!.home,
      ),
      BottomBarItem(
        inActiveItem: Icon(Icons.notifications, color: Colors.white),
        activeItem: Icon(Icons.notifications, color: Colors.white),
        itemLabel: S.of(context)!.notification,
      ),
      BottomBarItem(
        inActiveItem: Icon(Icons.person, color: Colors.white),
        activeItem: Icon(Icons.person, color: Colors.white),
        itemLabel: S.of(context)!.profile,
      ),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
            bottomBarPages.length, (index) => bottomBarPages[index]),
      ),
      extendBody: true,
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Color.fromARGB(255, 0, 0, 0),
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: Color.fromARGB(255, 202, 5, 5),
        removeMargins: false,
        bottomBarWidth: 500,
        showShadow: false,
        durationInMilliSeconds: 300,
        itemLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        elevation: 1,
        bottomBarItems: bottomBarItems,
        onTap: (index) {
          log('current selected index $index');
          _pageController.jumpToPage(index);
        },
        kIconSize: 24.0,
      ),
    );
  }
}
