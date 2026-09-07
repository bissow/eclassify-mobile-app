import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class DeleteMessagesDialog {
  static Future<bool?> show(BuildContext context, {required int count}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text(
                "${"delete".translate(context)} $count ${"messages".translate(context)}?",
                style: context.titleLarge,
                textAlign: TextAlign.center,
              ),
              Text(
                "deleteAdsDescription".translate(context),
                style: context.labelLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            AppButton(
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
              onPressed: () => Navigator.of(context).pop(false),
              title: "cancel",
            ),
            AppButton(
              variant: AppButtonVariant.filled,
              size: AppButtonSize.small,
              onPressed: () => Navigator.of(context).pop(true),
              title: "delete",
            ),
          ],
        );
      },
    );
  }
}
