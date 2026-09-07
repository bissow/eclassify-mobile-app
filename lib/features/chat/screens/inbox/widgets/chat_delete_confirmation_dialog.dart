import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class ChatDeleteConfirmationDialog {
  static Future<bool?> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'deleteChatTitle'.translate(context),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'deleteChatContent'.translate(context),
            textAlign: TextAlign.center,
          ),
          actions: [
            AppButton(
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
              onPressed: () => Navigator.of(context).pop(false),
              title: 'cancel',
            ),
            AppButton(
              variant: AppButtonVariant.filled,
              size: AppButtonSize.small,
              onPressed: () => Navigator.of(context).pop(true),
              title: 'confirm',
            ),
          ],
        );
      },
    );
  }
}
