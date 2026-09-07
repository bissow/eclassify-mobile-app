import 'package:eClassify/features/subscription/models/payment_gateway.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_dpo/payment_dpo.dart';
import 'package:payment_flutterwave/payment_flutterwave.dart';
import 'package:payment_paypal/payment_paypal.dart';
import 'package:payment_paystack/payment_paystack.dart';
import 'package:payment_paytabs/payment_paytabs.dart';
import 'package:payment_phonepe/payment_phonepe.dart';
import 'package:payment_razorpay/payment_razorpay.dart';
import 'package:payment_stripe/payment_stripe.dart';

/// Registers a [PaymentGatewayPlugin] for every currently-enabled gateway.
/// Only enabled gateways get a plugin — the registry itself enforces which
/// gateways are payable, not just the picker UI.
class PaymentGatewayRegistrar {
  const PaymentGatewayRegistrar._();

  static void register(List<PaymentGateway> gateways) {
    PaymentRegistry.clear();
    for (final gateway in gateways) {
      final plugin = _buildPlugin(gateway);
      if (plugin != null) PaymentRegistry.register(plugin);
    }
  }

  static PaymentGatewayPlugin? _buildPlugin(PaymentGateway gateway) {
    return switch (gateway) {
      StripeGateway() => StripeGatewayPlugin(),
      RazorpayGateway() => RazorpayGatewayPlugin(),
      PhonePeGateway() => PhonePeGatewayPlugin(),
      PaystackGateway() => PaystackGatewayPlugin(),
      FlutterwaveGateway() => FlutterwaveGatewayPlugin(),
      PayPalGateway() => PayPalGatewayPlugin(),
      DpoGateway() => DpoGatewayPlugin(),
      PayTabsGateway() => PayTabsGatewayPlugin(),
      // BankTransferGateway has no plugin — handled directly in PaymentHandler.
      _ => null,
    };
  }
}
