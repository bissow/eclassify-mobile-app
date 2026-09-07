import 'package:eClassify/core/constants/constant.dart';
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  Size sizeFromAspectRatio(double aspectRatio, {bool considerPadding = true}) {
    final width =
        screenWidth - (considerPadding ? Constant.horizontalPadding * 2 : 0);

    final height = width / aspectRatio;

    return Size(width, height);
  }
}
