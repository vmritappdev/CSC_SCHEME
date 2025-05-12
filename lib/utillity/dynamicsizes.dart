import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class SZ {
  // Width
  static double w(double width) => width.w;

  // Height
  static double h(double height) => height.h;

  // Font Size
  static double sp(double fontSize) => fontSize.sp;

  // Radius
  static double r(double radius) => radius.r;

  // Padding
  static EdgeInsets all(double value) => EdgeInsets.all(value.r);

  static EdgeInsets symmetric({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h.w, vertical: v.h);
}
