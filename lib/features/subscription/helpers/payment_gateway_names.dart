import 'package:eClassify/features/subscription/models/payment_gateway.dart';
import 'package:payment_core/payment_core.dart';

/// Maps a [PaymentGatewayType] to the backend's expected `payment_method`
/// string for the payment-intent API.
class PaymentGatewayNames {
  const PaymentGatewayNames._();

  static String of(PaymentGatewayType type) {
    return switch (type) {
      PaymentGatewayType.stripe => "Stripe",
      PaymentGatewayType.razorpay => "Razorpay",
      PaymentGatewayType.phonepe => "PhonePe",
      PaymentGatewayType.paystack => "Paystack",
      PaymentGatewayType.flutterwave => "FlutterWave",
      PaymentGatewayType.paypal => "PayPal",
      PaymentGatewayType.dpo => "DPO",
      PaymentGatewayType.paytabs => "Paytabs",
      AppPaymentGatewayType.bankTransfer => "bankTransfer",
      _ => throw UnimplementedError('No name for gateway "$type".'),
    };
  }
}
