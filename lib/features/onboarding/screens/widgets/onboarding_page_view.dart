import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:flutter/material.dart';

List kOnboardingList = [
  {
    'svg': AppAssets.illustrators.onboardingA,
    'title': "onboarding_1_title",
    'description': "onboarding_1_des",
  },
  {
    'svg': AppAssets.illustrators.onboardingB,
    'title': "onboarding_2_title",
    'description': "onboarding_2_des",
  },
  {
    'svg': AppAssets.illustrators.onboardingC,
    'title': "onboarding_3_title",
    'description': "onboarding_3_des",
  },
];

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({required this.controller, super.key});

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: kOnboardingList.length,
      itemBuilder: (context, index) {
        final data = kOnboardingList[index];
        return CustomImage(src: data['svg'] as String, fit: BoxFit.contain);
      },
    );
  }
}
