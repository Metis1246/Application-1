import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Language Provider
class LanguageProvider with ChangeNotifier {
  Locale _locale = Locale('en');

  LanguageProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  void setLocale(String languageCode) {
    _locale = Locale(languageCode);
    _saveLocale(languageCode);
    notifyListeners();
  }

  Future<void> _saveLocale(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', languageCode);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
        return MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.supportedLocales,
          locale: languageProvider.locale,
          debugShowCheckedModeBanner: false,
          home: LanguageScreen(),
        );
      }),
    );
  }
}

class LanguageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 18, 56, 226),
        elevation: 0,
        title: Text(
          S.of(context)!.lang,
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
      body: Center(
        child: LanguageSelection(),
      ),
    );
  }
}

class LanguageSelection extends StatefulWidget {
  @override
  _LanguageSelectionState createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  bool isEnglishSelected = true;

  void _selectLanguage(bool isEnglish) {
    setState(() {
      isEnglishSelected = isEnglish;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LanguageBox(
              text: S.of(context)!.thai,
              isSelected: !isEnglishSelected,
              onTap: () => _selectLanguage(false),
            ),
            SizedBox(width: 20),
            _LanguageBox(
              text: S.of(context)!.eng,
              isSelected: isEnglishSelected,
              onTap: () => _selectLanguage(true),
            ),
          ],
        ),
        SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            String languageCode = isEnglishSelected ? 'en' : 'th';
            Provider.of<LanguageProvider>(context, listen: false)
                .setLocale(languageCode);
            Navigator.pop(context);
          },
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
      ],
    );
  }
}

class _LanguageBox extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  _LanguageBox({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color:
              isSelected ? Color.fromARGB(255, 18, 56, 226) : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
