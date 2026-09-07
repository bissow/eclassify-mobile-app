import 'package:eClassify/core/models/version.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionUpdateDialog {
  static void show(
    BuildContext context, {
    required Version availableVersion,
    required bool isForceUpdate,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (context) {
        return PopScope(
          canPop: !isForceUpdate,
          child: AppDialog(
            title: Text(
              'updateAvailable'.translate(context),
              textAlign: TextAlign.center,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Center(
                  child: Text(
                    availableVersion.toString(),
                    style: context.titleMedium,
                  ),
                ),
                Text('newVersionAvailable'.translate(context)),
                if (isForceUpdate) Text('forceUpdate'.translate(context)),
              ],
            ),
            actions: [
              if (!isForceUpdate)
                Expanded(
                  child: AppButton(
                    variant: AppButtonVariant.outlined,
                    size: AppButtonSize.small,
                    foregroundColor: context.colorScheme.onSurface,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    title: 'cancel',
                  ),
                ),
              Expanded(
                child: AppButton(
                  variant: AppButtonVariant.filled,
                  size: AppButtonSize.small,
                  foregroundColor: context.colorScheme.secondary,
                  backgroundColor: context.colorScheme.primary,
                  onPressed: () {
                    final uri = Uri.tryParse(
                      Constant.systemSettings.storeLink ?? '',
                    );
                    if (uri == null) return;
                    launchUrl(uri);
                  },
                  title: 'update',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
