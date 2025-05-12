import 'package:flutter/material.dart';

class ScreenUtils {
  static bool isSmallScreen(BuildContext context) {
  return MediaQuery.of(context).size.width < 360;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 360 &&
        MediaQuery.of(context).size.width < 720;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 720;
  }
}
