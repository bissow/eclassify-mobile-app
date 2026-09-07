import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/text/expandable_text.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class AdminEditedCard extends StatelessWidget {
  const AdminEditedCard({required this.reason, super.key});

  final String reason;

  @override
  Widget build(BuildContext context) {
    if (reason.isNullOrEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colorScheme.error),
      ),
      child: Row(
        spacing: 15,
        children: [
          CustomImage(
            src: AppAssets.common.adminEdit,
            color: context.colorScheme.error,
            size: Size.square(36),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'adEditedByAdmin'.translate(context),
                  style: context.labelLarge,
                ),
                ExpandableText(
                  text: reason,
                  maxLines: 2,
                  style: context.labelMedium,
                  readMoreButtonStyle: context.labelMedium.withColor(
                    context.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
