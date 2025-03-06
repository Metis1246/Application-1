//import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

class OTPService {
  Future<void> sendOtp(String email) async {
    final otp = Random().nextInt(900000) + 100000;

    String username = 'firebase0078@gmail.com';
    String password = 'zaqxswTH0';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Your App Name')
      ..recipients.add(email)
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is: $otp';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Message not sent: ' + e.toString());
    }
  }
}
