import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gender.dart';
import 'load.dart';
import 'package:intl/intl.dart';
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
      home: ListScreen(),
    );
  }
}

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String selectedDay = '01';
  String selectedMonth = 'January';
  String selectedYear = '1990';
  String selectedWeight = '75';
  String selectedHeight = '175';
  String selectedBox = '';

  double _calculateBMI(double weight, double height) {
    return weight / ((height / 100) * (height / 100));
  }

  double _calculateBMR(double weight, double height, int age, String gender) {
    if (gender == 'Men') {
      return (66 + (13.7 * weight) + (5 * height) - (6.8 * age))
          .toInt()
          .toDouble();
    } else {
      return (665 + (9.6 * weight) + (1.8 * height) - (4.7 * age))
          .toInt()
          .toDouble();
    }
  }

  // Define a mapping of months to their corresponding number of days
  Map<String, int> daysInMonth = {
    'January': 31,
    'February': 28,
    'March': 31,
    'April': 30,
    'May': 31,
    'June': 30,
    'July': 31,
    'August': 31,
    'September': 30,
    'October': 31,
    'November': 30,
    'December': 31,
    'มกราคม': 31,
    'กุมภาพันธ์': 28,
    'มีนาคม': 31,
    'เมษายน': 30,
    'พฤษภาคม': 31,
    'มิถุนายน': 30,
    'กรกฎาคม': 31,
    'สิงหาคม': 31,
    'กันยายน': 30,
    'ตุลาคม': 31,
    'พฤศจิกายน': 30,
    'ธันวาคม': 31,
  };

  List<String> getDaysForSelectedMonth() {
    if (daysInMonth.containsKey(selectedMonth)) {
      int days = daysInMonth[selectedMonth]!;
      return List.generate(
          days, (index) => (index + 1).toString().padLeft(2, '0'));
    } else {
      print('Invalid month: $selectedMonth'); // เพิ่มบรรทัดนี้เพื่อตรวจสอบ
      return []; // คืนค่ารายการว่างเพื่อหลีกเลี่ยงข้อผิดพลาด
    }
  }

  List<String> get months {
    return [
      S.of(context)!.jan, //31
      S.of(context)!.feb, //28
      S.of(context)!.mar, //31
      S.of(context)!.apr, //30
      S.of(context)!.may, //31
      S.of(context)!.june, //30
      S.of(context)!.july, //31
      S.of(context)!.aug, //31
      S.of(context)!.sep, //30
      S.of(context)!.oct, //31
      S.of(context)!.nov, //30
      S.of(context)!.dec //31
    ];
  }

  List<String> years = [];

  @override
  void initState() {
    super.initState();
    if (!years.contains(selectedYear)) {
      selectedYear = years.isNotEmpty ? years[0] : '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeYears(); // เรียกใน didChangeDependencies แทน
  }

  void _initializeYears() {
    // สร้างรายการปีโดยใช้ localization strings สำหรับ year1 ถึง year30
    years = List.generate(30, (index) {
      // เข้าถึงปีตามลำดับโดยใช้ `S` class
      final yearIndex = index + 1;
      switch (yearIndex) {
        case 1:
          return S.of(context)!.year1;
        case 2:
          return S.of(context)!.year2;
        case 3:
          return S.of(context)!.year3;
        case 4:
          return S.of(context)!.year4;
        case 5:
          return S.of(context)!.year5;
        case 6:
          return S.of(context)!.year6;
        case 7:
          return S.of(context)!.year7;
        case 8:
          return S.of(context)!.year8;
        case 9:
          return S.of(context)!.year9;
        case 10:
          return S.of(context)!.year10;
        case 11:
          return S.of(context)!.year11;
        case 12:
          return S.of(context)!.year12;
        case 13:
          return S.of(context)!.year13;
        case 14:
          return S.of(context)!.year14;
        case 15:
          return S.of(context)!.year15;
        case 16:
          return S.of(context)!.year16;
        case 17:
          return S.of(context)!.year17;
        case 18:
          return S.of(context)!.year18;
        case 19:
          return S.of(context)!.year19;
        case 20:
          return S.of(context)!.year20;
        case 21:
          return S.of(context)!.year21;
        case 22:
          return S.of(context)!.year22;
        case 23:
          return S.of(context)!.year23;
        case 24:
          return S.of(context)!.year24;
        case 25:
          return S.of(context)!.year25;
        case 26:
          return S.of(context)!.year26;
        case 27:
          return S.of(context)!.year27;
        case 28:
          return S.of(context)!.year28;
        case 29:
          return S.of(context)!.year29;
        case 30:
          return S.of(context)!.year30;
        default:
          return '';
      }
    });
  }

  List<String> weights = List.generate(86, (index) => '${index + 45}');
  List<String> heights = List.generate(51, (index) => '${index + 150}');

  void _saveUserInfoToFirestore(
      String userId, Map<String, dynamic> userInfo) async {
    try {
      double weight = double.parse(userInfo['weight']);
      double height = double.parse(userInfo['height']);
      int age = userInfo['age'];
      String gender = 'Men';

      double bmi = _calculateBMI(weight, height);
      double bmr = _calculateBMR(weight, height, age, gender);

      userInfo['bmi'] = bmi.toStringAsFixed(2);
      userInfo['bmr'] = bmr.toInt();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userInfo, SetOptions(merge: true));
      print('ข้อมูลผู้ใช้ถูกบันทึกเรียบร้อยแล้ว');
    } catch (e) {
      print('ไม่สามารถบันทึกข้อมูลผู้ใช้ได้: $e');
    }
  }

  int _calculateAge(String birthDateString) {
    // พยายามแปลงวันเกิดจากสตริงเป็น DateTime
    DateTime birthDate;

    // ตรวจสอบว่าปีในสตริงนั้นเป็นปี พ.ศ. หรือไม่
    try {
      birthDate = DateFormat('dd MMMM yyyy', 'th').parse(birthDateString);
      if (birthDate.year > 2400) {
        // แปลงจาก พ.ศ. เป็น ค.ศ.
        birthDate =
            DateTime(birthDate.year - 543, birthDate.month, birthDate.day);
      }
    } catch (e) {
      // หากเกิดข้อผิดพลาด ให้แปลงเป็น DateTime ในรูปแบบภาษาอังกฤษ
      birthDate = DateFormat('dd MMMM yyyy').parse(birthDateString);
    }

    // คำนวณอายุ
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 40.0,
            left: 20.0,
            child: Container(
              width: 55.0,
              height: 55.0,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 202, 5, 5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Transform.translate(
                  offset: Offset(5.0, 0),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 36.0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GenderSelectionScreen()),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 300.0,
              height: 320.0,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 202, 5, 5),
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: Offset(6.0, 6.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDateField(),
                  SizedBox(height: 20.0),
                  _buildWeightHeightFields(),
                  SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBox(
                        const Color.fromARGB(255, 255, 255, 255),
                        S.of(context)!.lose,
                        S.of(context)!.lose,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        S.of(context)!.or,
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      _buildBox(
                        const Color.fromARGB(255, 255, 255, 255),
                        S.of(context)!.gain,
                        S.of(context)!.gain,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.02,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: GestureDetector(
              onTap: () {
                if (selectedBox.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select Lose Weight OR Gain Weight'),
                    ),
                  );
                  return;
                }

                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  String userId = user.uid;
                  String date = '$selectedDay $selectedMonth $selectedYear';
                  int age = _calculateAge(date);
                  Map<String, dynamic> userInfo = {
                    'date': date,
                    'weight': selectedWeight,
                    'height': selectedHeight,
                    'goal': selectedBox,
                    'rank': 0,
                    'age': age,
                  };

                  _saveUserInfoToFirestore(userId, userInfo);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoadingScreen()),
                  );
                } else {
                  print('No user is logged in');
                }
              },
              child: Container(
                height: screenHeight * 0.08,
                decoration: BoxDecoration(
                  color: selectedBox.isEmpty
                      ? Color.fromARGB(255, 169, 169, 169)
                      : Color.fromARGB(255, 202, 5, 5),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(6.0, 6.0),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    S.of(context)!.next,
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            S.of(context)!.date,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                color: const Color.fromARGB(255, 255, 255, 255),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDropdownField(getDaysForSelectedMonth(), selectedDay,
                (newValue) {
              setState(() {
                selectedDay = newValue!;
              });
            }, width: 50.0),
            SizedBox(width: 10.0),
            _buildDropdownField(months, selectedMonth, (newValue) {
              setState(() {
                selectedMonth = newValue!;
              });
            }, width: 110.0),
            SizedBox(width: 10.0),
            _buildDropdownField(years, selectedYear, (newValue) {
              setState(() {
                selectedYear = newValue!;
              });
            }, width: 90.0),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightHeightFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    S.of(context)!.weight,
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
                _buildDropdownField(weights, selectedWeight, (newValue) {
                  setState(() {
                    selectedWeight = newValue!;
                  });
                }, width: 100.0),
              ],
            ),
            SizedBox(width: 18.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    S.of(context)!.height,
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
                _buildDropdownField(heights, selectedHeight, (newValue) {
                  setState(() {
                    selectedHeight = newValue!;
                  });
                }, width: 100.0),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBox(Color color, String text, String boxIdentifier) {
    bool isSelected = selectedBox == boxIdentifier;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBox = isSelected ? '' : boxIdentifier;
        });
      },
      child: AnimatedContainer(
        width: 110.0,
        height: 110.0,
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Color.fromARGB(255, 169, 169, 169) : color,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      List<String> items, String selectedItem, ValueChanged<String?> onChanged,
      {bool isWide = false, double width = 85.0}) {
    List<String> uniqueItems = items.toSet().toList();
    String effectiveSelectedItem =
        uniqueItems.contains(selectedItem) ? selectedItem : uniqueItems.first;

    return Container(
      width: width,
      height: 40.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.grey, width: 1.0),
      ),
      child: Center(
        child: DropdownButton<String>(
          value: effectiveSelectedItem,
          isExpanded: true,
          underline: SizedBox(),
          items: uniqueItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Center(
                child: Text(
                  value,
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
