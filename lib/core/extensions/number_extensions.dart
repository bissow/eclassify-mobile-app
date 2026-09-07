import 'package:eClassify/core/models/currency.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension NumberExtension on num {
  String get compact {
    final currentLocale = AppSession.currentLocale;
    final localeExists = NumberFormat.localeExists(currentLocale);
    final effectiveLocale = localeExists ? currentLocale : 'en_US';
    final formatter = NumberFormat.compact(locale: effectiveLocale);
    return formatter.format(this);
  }
}

extension CurrencyExtension on num {
  String currencyFormat([Currency? currency]) {
    final formatted = this.decimalFormat;

    if (currency != null) {
      return NumberFormat.currency(
        name: currency.code,
        symbol: currency.symbol,
      ).format(this);
    }

    return Constant.systemSettings.defaultCurrency.isSymbolOnLeft
        ? '${Constant.systemSettings.defaultCurrency.symbol} $formatted'
        : '$formatted ${Constant.systemSettings.defaultCurrency.symbol}';
  }

  String get decimalFormat {
    final supportsLocale = NumberFormat.localeExists(AppSession.currentLocale);
    final numberFormat = NumberFormat.decimalPatternDigits(
      locale: supportsLocale ? AppSession.currentLocale : Intl.defaultLocale,
      decimalDigits: 2,
    );
    return numberFormat.format(this);
  }
}

extension Gap on num {
  Widget get vGap => SizedBox(height: this.toDouble());

  Widget get hGap => SizedBox(width: this.toDouble());
}

extension SizeExtension on num {
  String formatBytes([int decimals = 2]) {
    if (isNaN || this < 0) return '0 B';
    if (this < 1024) return '${toStringAsFixed(decimals)} B';
    if (this < 1024 * 1024) {
      return '${(this / 1024).toStringAsFixed(decimals)} KB';
    }
    return '${(this / (1024 * 1024)).toStringAsFixed(decimals)} MB';
  }
}
