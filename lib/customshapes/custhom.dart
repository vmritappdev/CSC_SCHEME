import 'package:flutter/material.dart';

class CustomNotchedShape extends CircularNotchedRectangle {
  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null) {
      return Path()..addRect(host);
    }

    final double notchRadius = guest.width / 2.0;
    final Path path = Path()
      ..moveTo(host.left, host.top)
      ..lineTo(guest.left - notchRadius, host.top)
      ..arcToPoint(
        Offset(guest.right + notchRadius, host.top),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();

    return path;
  }
}
