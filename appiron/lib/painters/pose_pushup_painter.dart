import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this.pushUpCountNotifier,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final ValueNotifier<int> pushUpCountNotifier;

  bool isPreviousPushUpCorrect = false;
  bool wasInCorrectPushUpPosition = false;
  int pushUpPhase = 0;
  int correctPushUpLineCount = 0;

  int pushUpCounter = 0;

  @override
  void paint(Canvas canvas, Size size) {
    final correctPushUpPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Color.fromARGB(255, 23, 197, 7);
    final incorrectPushUpPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Color.fromARGB(255, 5, 72, 218);
    final noPushUpPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    correctPushUpLineCount = 0;

    for (final pose in poses) {
      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        if (pose.landmarks.containsKey(type1) &&
            pose.landmarks.containsKey(type2)) {
          final PoseLandmark joint1 = pose.landmarks[type1]!;
          final PoseLandmark joint2 = pose.landmarks[type2]!;
          canvas.drawLine(
              Offset(
                  translateX(
                    joint1.x,
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                  translateY(
                    joint1.y,
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  )),
              Offset(
                  translateX(
                    joint2.x,
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                  translateY(
                    joint2.y,
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  )),
              paintType);

          // เพิ่มตัวนับเส้นสีฟ้า
          if (paintType == incorrectPushUpPaint) {
            correctPushUpLineCount++;
          }
        }
      }

      bool isCorrectPushUp = false;
      bool isPushUpAttempted = false;

      if (pose.landmarks.containsKey(PoseLandmarkType.leftShoulder) &&
          pose.landmarks.containsKey(PoseLandmarkType.rightShoulder) &&
          pose.landmarks.containsKey(PoseLandmarkType.leftElbow) &&
          pose.landmarks.containsKey(PoseLandmarkType.rightElbow) &&
          pose.landmarks.containsKey(PoseLandmarkType.leftWrist) &&
          pose.landmarks.containsKey(PoseLandmarkType.rightWrist)) {
        final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
        final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder]!;
        final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow]!;
        final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow]!;

        isPushUpAttempted = true;
        if (leftElbow.y > leftShoulder.y + 50 &&
            rightElbow.y > rightShoulder.y + 50) {
          isCorrectPushUp = true; // เฟสลง (สีเขียว)
          print('เฟสลง: isCorrectPushUp = $isCorrectPushUp');
        }

        if (leftElbow.y < leftShoulder.y - 10 &&
            rightElbow.y < rightShoulder.y - 10) {
          isCorrectPushUp = false; // เฟสขึ้น
          print('เฟสขึ้น: isCorrectPushUp = $isCorrectPushUp');
        }

        if (isCorrectPushUp && !isPreviousPushUpCorrect) {
          wasInCorrectPushUpPosition = true;
          print('เฟสลง: isCorrectPushUp = true');
        } else if (!isCorrectPushUp && wasInCorrectPushUpPosition) {
          if (correctPushUpLineCount >= 1) {
            pushUpCounter++; // เพิ่มค่าตัวแปรเมื่อเงื่อนไขครบถ้วน
            pushUpCountNotifier.value =
                pushUpCounter; // อัปเดต pushUpCountNotifier
            print('Push-up count เพิ่มขึ้น: $pushUpCounter');
          } else {
            print(
                'เฟสขึ้นแต่ไม่มีการนับ: correctPushUpLineCount = $correctPushUpLineCount');
          }
          wasInCorrectPushUpPosition = false;
          correctPushUpLineCount =
              0; // รีเซ็ตตัวแปรหลังจากที่ตรวจจับเฟสเรียบร้อย
          print('ออกจากตำแหน่งที่ถูกต้อง: $wasInCorrectPushUpPosition');
        }

        isPreviousPushUpCorrect = isCorrectPushUp;
      }

      final paintColor = isCorrectPushUp
          ? correctPushUpPaint
          : (isPushUpAttempted ? incorrectPushUpPaint : noPushUpPaint);

      // วาดแขน
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow,
          paintColor);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, paintColor);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          paintColor);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, paintColor);

      // วาดบอดี้
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, paintColor);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          paintColor);

      // วาดขา
      paintLine(
          PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, paintColor);
      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, paintColor);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, paintColor);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, paintColor);
    }

    // แสดงผลจำนวน push-up
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Push-ups: ${pushUpCountNotifier.value}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 10));
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}
