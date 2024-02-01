import 'package:flutter/material.dart';

class OvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xff01ff0b).withOpacity(.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radiusX = size.width / 2;
    double radiusY = size.height / 2;

    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(centerX, centerY), width: radiusX, height: radiusY),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
