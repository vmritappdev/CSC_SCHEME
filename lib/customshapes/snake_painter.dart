import 'package:flutter/material.dart';

class SnakePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white;
    Path path = Path();

    double waveHeight = 10;
    double waveWidth = size.width / 20;

    path.moveTo(0, 0);
    for (double i = 0; i <= size.width; i += waveWidth) {
      path.quadraticBezierTo(
        i + waveWidth / 4,
        waveHeight,
        i + waveWidth / 2,
        0,
      );
      path.quadraticBezierTo(
        i + waveWidth * 3 / 4,
        -waveHeight,
        i + waveWidth,
        0,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
