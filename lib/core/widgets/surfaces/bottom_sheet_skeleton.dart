import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:flutter/material.dart';

class BottomSheetSkeleton extends StatelessWidget {
  const BottomSheetSkeleton({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(padding: Constant.safeAreaMinimumPadding, child: child),
      ),
    );
  }
}
