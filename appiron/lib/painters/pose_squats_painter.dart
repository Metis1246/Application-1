import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'coordinates_translator.dart';
import '../painters/score.dart';

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this.squatCountNotifier,
    this.context, // รับ BuildContext
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final ValueNotifier<int> squatCountNotifier;
  final BuildContext context; // เก็บ BuildContext

  bool isDownPhase = false;
  bool isUpPhase = false;
  bool isSquatCounting = false;
  bool isProcessing = false;
  int completedRounds = 0;
  bool hasNavigatedToScorePage =
      false; // ตัวแปรเพื่อตรวจสอบการนำทางไปยัง ScorePage

  @override
  void paint(Canvas canvas, Size size) {
    final correctSquatPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.green;

    final noSquatPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    final landmarkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue;

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
        }
      }

      void paintPoint(PoseLandmarkType type, Paint paintType) {
        if (pose.landmarks.containsKey(type)) {
          final PoseLandmark joint = pose.landmarks[type]!;
          canvas.drawCircle(
            Offset(
              translateX(
                joint.x,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
              translateY(
                joint.y,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
            ),
            6.0, // ขนาดของจุด landmark
            paintType,
          );
        }
      }

      bool isDownPhaseDetected = false;
      bool isUpPhaseDetected = false;

      if (pose.landmarks.containsKey(PoseLandmarkType.leftHip) &&
          pose.landmarks.containsKey(PoseLandmarkType.rightHip) &&
          pose.landmarks.containsKey(PoseLandmarkType.leftKnee) &&
          pose.landmarks.containsKey(PoseLandmarkType.rightKnee)) {
        final leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
        final rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;
        final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee]!;
        final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee]!;

        // เงื่อนไขเฟส Down
        if ((leftKnee.y - leftHip.y > -80) &&
            (rightKnee.y - rightHip.y > -80)) {
          isDownPhaseDetected = true;
        }

        // เงื่อนไขเฟส Up
        if ((leftHip.y - leftKnee.y > -50) &&
            (rightHip.y - rightKnee.y > -50)) {
          isUpPhaseDetected = true;
        }
      }

      final paintColor = (isDownPhaseDetected || isUpPhaseDetected)
          ? correctSquatPaint
          : noSquatPaint;

      // ตรวจจับและจัดการเฟส Down
      if (isDownPhaseDetected && !isDownPhase) {
        isDownPhase = true;
        isUpPhase = false;
        isSquatCounting = true;
      }

      if (squatCountNotifier.value < 15) {
        if (isSquatCounting &&
            isUpPhaseDetected &&
            isDownPhase &&
            !isUpPhase &&
            !isProcessing) {
          isUpPhase = true;
          isSquatCounting = false;
          isProcessing = true;

          squatCountNotifier.value += 1;
          print("Squat Count: ${squatCountNotifier.value}");

          Future.delayed(Duration(milliseconds: 650), () {
            completedRounds++;
            isDownPhase = false;
            isSquatCounting = true;
            isProcessing = false;
          });
        }
      }

      if (!isDownPhaseDetected) {
        isDownPhase = false;
      }

      if (!isUpPhaseDetected) {
        isUpPhase = false;
      }

      // วาดเส้นเชื่อมระหว่างสะโพก เข่า และ เท้า
      paintLine(
          PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, paintColor);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, paintColor);
      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, paintColor);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, paintColor);

      // วาดจุด landmark สำหรับสะโพก เข่า และ เท้า
      paintPoint(PoseLandmarkType.leftHip, landmarkPaint);
      paintPoint(PoseLandmarkType.rightHip, landmarkPaint);
      paintPoint(PoseLandmarkType.leftKnee, landmarkPaint);
      paintPoint(PoseLandmarkType.rightKnee, landmarkPaint);
      paintPoint(PoseLandmarkType.leftAnkle, landmarkPaint);
      paintPoint(PoseLandmarkType.rightAnkle, landmarkPaint);

      // แสดงผลจำนวน Squats
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Squats: ${squatCountNotifier.value}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
          canvas, Offset(16, size.height - textPainter.height - 16));

      // วาดแท่งแสดงความคืบหน้าด้านข้าง
      double barWidth = 20;
      double maxBarHeight = size.height * 0.8;
      double barHeight;

      if (squatCountNotifier.value >= 1 && squatCountNotifier.value <= 4) {
        barHeight = maxBarHeight * 0.2;
      } else {
        barHeight = (squatCountNotifier.value / 15) * maxBarHeight;

        // เช็คและนำทางไปยัง ScorePage
        if (squatCountNotifier.value >= 15 && !hasNavigatedToScorePage) {
          hasNavigatedToScorePage = true; // ป้องกันไม่ให้ทำการนำทางซ้ำ
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ScorePage()),
            );
          });
        }
      }

      canvas.drawRect(
        Rect.fromLTWH(size.width - barWidth - 16, size.height - barHeight - 16,
            barWidth, barHeight),
        Paint()..color = Colors.green,
      );

      // วาดขอบแท่งแสดงความคืบหน้า
      canvas.drawRect(
        Rect.fromLTWH(size.width - barWidth - 16,
            size.height - maxBarHeight - 16, barWidth, maxBarHeight),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.rotation != rotation ||
        oldDelegate.cameraLensDirection != cameraLensDirection ||
        oldDelegate.squatCountNotifier.value != squatCountNotifier.value;
  }
}
