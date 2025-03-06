import 'dart:async'; // เพิ่มการใช้ Timer
import '../painters/score.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'coordinates_translator.dart';

class PosePlankPainter extends CustomPainter {
  PosePlankPainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this.plankTimeNotifier,
    this.countdownNotifier,
    this.context,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final ValueNotifier<Duration> plankTimeNotifier;
  final ValueNotifier<int> countdownNotifier;
  final BuildContext context;
  Timer? _countdownTimer;

  bool _isPlankPositionDetected = false;

  @override
  void paint(Canvas canvas, Size size) {
    final correctPlankPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.green;

    final incorrectPlankPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue
      ..strokeWidth = 6.0;

    for (final pose in poses) {
      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        if (pose.landmarks.containsKey(type1) &&
            pose.landmarks.containsKey(type2)) {
          final PoseLandmark joint1 = pose.landmarks[type1]!;
          final PoseLandmark joint2 = pose.landmarks[type2]!;

          final joint1Offset = Offset(
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
            ),
          );

          final joint2Offset = Offset(
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
            ),
          );

          canvas.drawLine(joint1Offset, joint2Offset, paintType);
          canvas.drawCircle(joint1Offset, 5.0, dotPaint);
          canvas.drawCircle(joint2Offset, 5.0, dotPaint);
        }
      }

      bool isPlankPositionDetected = false;

      if (pose.landmarks.containsKey(PoseLandmarkType.leftShoulder) &&
          pose.landmarks.containsKey(PoseLandmarkType.rightShoulder) &&
          pose.landmarks.containsKey(PoseLandmarkType.leftHip) &&
          pose.landmarks.containsKey(PoseLandmarkType.rightHip) &&
          pose.landmarks.containsKey(PoseLandmarkType.leftKnee) &&
          pose.landmarks.containsKey(PoseLandmarkType.rightKnee) &&
          pose.landmarks.containsKey(PoseLandmarkType.leftAnkle) &&
          pose.landmarks.containsKey(PoseLandmarkType.rightAnkle)) {
        final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
        final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder]!;
        final leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
        final rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;
        final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee]!;
        final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee]!;
        final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle]!;
        final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle]!;

        final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
        final hipY = (leftHip.y + rightHip.y) / 2;
        final kneeY = (leftKnee.y + rightKnee.y) / 2;

        final isShoulderHigherThanHip = shoulderY < hipY;
        final isHipHigherThanKnee = hipY < kneeY;

        if (isShoulderHigherThanHip && isHipHigherThanKnee) {
          isPlankPositionDetected = true;
        }

        // Use incorrect color until the position is detected
        final paintColor =
            isPlankPositionDetected ? incorrectPlankPaint : correctPlankPaint;

        // Draw lines for the detected landmarks
        paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow,
            paintColor);
        paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
            paintColor);
        paintLine(
            PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, paintColor);
        paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist,
            paintColor);
        paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip,
            paintColor);
        paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
            paintColor);
        paintLine(
            PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, paintColor);
        paintLine(
            PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, paintColor);
        paintLine(
            PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, paintColor);
        paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle,
            paintColor);

        // Handle the plank position detection and countdown
        if (isPlankPositionDetected) {
          if (!_isPlankPositionDetected) {
            _isPlankPositionDetected = true;

            plankTimeNotifier.value = Duration.zero;
            countdownNotifier.value = 20;

            _countdownTimer?.cancel();
            _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
              if (countdownNotifier.value > 0) {
                countdownNotifier.value--;
                plankTimeNotifier.value =
                    Duration(seconds: 20 - countdownNotifier.value);
              } else {
                timer.cancel();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ScorePage()),
                );
              }
            });
          }
        } else {
          if (_isPlankPositionDetected) {
            _isPlankPositionDetected = false;
            _countdownTimer?.cancel();
            countdownNotifier.value = 20;
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
