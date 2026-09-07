import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/features/subscription/cubits/payment_methods_cubit.dart';
import 'package:eClassify/features/subscription/models/payment_gateway.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_core/payment_core.dart';

/// The sole gateway-picker UI, built from the currently enabled gateways
/// held by [PaymentMethodsCubit].
class PaymentMethodSelectorSheet {
  const PaymentMethodSelectorSheet._();

  static Future<PaymentGatewayType?> show(BuildContext context) async {
    final state = context.read<PaymentMethodsCubit>().state;
    final gateways = state is PaymentMethodsSuccess
        ? state.gateways
        : const <PaymentGateway>[];

    if (gateways.isEmpty) {
      HelperUtils.showSnackBarMessage(
        context,
        'noPaymentMethodAvailable'.translate(context),
      );
      return null;
    }

    // Only one gateway configured from the panel — nothing to pick between,
    // so skip the sheet and go straight to it.
    if (gateways.length == 1) return gateways.single.type;

    return showModalBottomSheet<PaymentGatewayType>(
      context: context,
      backgroundColor: context.colorScheme.secondary,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: Constant.appContentPadding,
          children: [
            Text(
              'selectPaymentMethod'.translate(context),
              style: context.titleMedium.bold,
            ),
            ...gateways.map(
              (gateway) => ListTile(
                leading: CustomImage(
                  src: _iconFor(gateway.type),
                  size: const Size.square(24),
                ),
                title: Text(gateway.displayName),
                onTap: () => Navigator.pop(context, gateway.type),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _iconFor(PaymentGatewayType type) {
    if (type == PaymentGatewayType.stripe) return AppAssets.payment.stripe;
    if (type == PaymentGatewayType.razorpay) return AppAssets.payment.razorpay;
    if (type == PaymentGatewayType.phonepe) return AppAssets.payment.phonePe;
    if (type == PaymentGatewayType.paystack) return AppAssets.payment.paystack;
    if (type == PaymentGatewayType.flutterwave) {
      return AppAssets.payment.flutterwave;
    }
    if (type == PaymentGatewayType.paypal) return AppAssets.payment.paypal;
    if (type == PaymentGatewayType.dpo) return AppAssets.payment.dpo;
    if (type == PaymentGatewayType.paytabs) return AppAssets.payment.paytabs;
    if (type == AppPaymentGatewayType.bankTransfer) {
      return AppAssets.payment.bankTransfer;
    }
    return '';
  }
}
