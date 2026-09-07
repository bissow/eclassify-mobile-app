import 'package:eClassify/app/app_localization.dart';
import 'package:flutter/cupertino.dart';

extension Translate on String {
  String translate(BuildContext context, [Map<String, String>? parameters]) {
    var translatedText =
        (AppLocalization.of(context)!.getTranslatedValues(this) ?? this).trim();
    if (parameters != null) {
      for (var key in parameters.keys) {
        translatedText = translatedText.replaceAll(
          '{$key}',
          parameters[key] ?? '',
        );
      }
    }
    return translatedText;
  }
}

extension CaseExtensions on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}
