import 'dart:convert';

import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_dpo/payment_dpo.dart';
import 'package:payment_flutterwave/payment_flutterwave.dart';
import 'package:payment_paypal/payment_paypal.dart';
import 'package:payment_paystack/payment_paystack.dart';
import 'package:payment_paytabs/payment_paytabs.dart';
import 'package:payment_phonepe/payment_phonepe.dart';
import 'package:payment_razorpay/payment_razorpay.dart';
import 'package:payment_stripe/payment_stripe.dart';

/// Builds the gateway-specific [PaymentRequest] out of the raw
/// `payment_gateway_response` returned by the backend's payment-intent API.
class PaymentRequestGenerator {
  const PaymentRequestGenerator._();

  static PaymentRequest generatePaymentRequest({
    required PaymentGatewayType type,
    required Json paymentIntent,
    String? apiKey,
  }) {
    return switch (type) {
      PaymentGatewayType.stripe => _stripeRequest(paymentIntent, apiKey ?? ''),
      PaymentGatewayType.razorpay => _razorpayRequest(
        paymentIntent,
        apiKey ?? '',
      ),
      PaymentGatewayType.phonepe => _phonePeRequest(paymentIntent),
      PaymentGatewayType.paystack => _paystackRequest(paymentIntent),
      PaymentGatewayType.flutterwave => _flutterwaveRequest(paymentIntent),
      PaymentGatewayType.paypal => _payPalRequest(paymentIntent),
      PaymentGatewayType.dpo => _dpoRequest(paymentIntent),
      PaymentGatewayType.paytabs => _payTabsRequest(paymentIntent),
      _ => throw UnimplementedError(
        'No request generator for gateway "$type".',
      ),
    };
  }

  static StripeRequest _stripeRequest(Json intent, String publishableKey) {
    final gatewayResponse = intent['payment_gateway_response'] as Json;
    final clientSecret = gatewayResponse['client_secret']?.toString() ?? '';
    return StripeRequest(
      clientSecret: clientSecret,
      merchantDisplayName: AppConfig.applicationName,
      publishableKey: publishableKey,
    );
  }

  static RazorpayRequest _razorpayRequest(Json intent, String razorpayKey) {
    final amount = int.tryParse(intent['amount']?.toString() ?? '');
    final currency = intent['currency']?.toString() ?? '';
    final orderId = intent['id']?.toString() ?? '';

    if (amount == null || currency.isEmpty || orderId.isEmpty) {
      throw Exception('Invalid payment intent data');
    }

    return RazorpayRequest(
      razorpayKey: razorpayKey,
      amount: amount,
      currency: currency,
      orderId: orderId,
    );
  }

  static PhonePeRequest _phonePeRequest(Json intent) {
    final gatewayResponse = intent['payment_gateway_response'] as Json;
    final merchantId = gatewayResponse['merchantId']?.toString() ?? '';
    final environment = gatewayResponse['environment']?.toString() ?? '';
    final flowId = gatewayResponse['flowId']?.toString() ?? '';
    final merchantOrderId =
        gatewayResponse['request']?['merchantOrderId']?.toString() ?? '';

    final request = {
      "orderId": intent['id'].toString(),
      "merchantId": merchantId,
      "merchantOrderId": merchantOrderId,
      "token": gatewayResponse['request']['token'],
      "paymentMode": {"type": "PAY_PAGE"},
    };

    return PhonePeRequest(
      base64Payload: jsonEncode(request),
      merchantId: merchantId,
      merchantTransactionId: merchantOrderId,
      environment: environment,
      flowId: flowId,
    );
  }

  static PaystackRequest _paystackRequest(Json intent) {
    final gatewayResponse = intent['payment_gateway_response'] as Json;
    final checkoutUrl =
        gatewayResponse['data']['authorization_url']?.toString() ?? '';
    final transactionReference =
        gatewayResponse['data']['reference']?.toString() ?? '';

    return PaystackRequest(
      checkoutUrl: checkoutUrl,
      returnUrlPrefix: AppConfig.hostUrl,
      transactionReference: transactionReference,
    );
  }

  static FlutterwaveRequest _flutterwaveRequest(Json intent) {
    final gatewayResponse = intent['payment_gateway_response'] as Json;
    return FlutterwaveRequest(
      checkoutUrl: gatewayResponse['data']?['link']?.toString() ?? '',
      returnUrlPrefix: AppConfig.hostUrl,
      transactionReference:
          gatewayResponse['data']?['tx_ref']?.toString() ??
          intent['id'].toString(),
    );
  }

  static DpoRequest _dpoRequest(Json intent) {
    final gatewayResponse = intent['payment_gateway_response'] as Json;
    return DpoRequest(
      checkoutUrl: gatewayResponse['payment_url']?.toString() ?? '',
      returnUrlPrefix: AppConfig.hostUrl,
      transactionReference:
          gatewayResponse['TransToken']?.toString() ?? intent['id'].toString(),
    );
  }

  static PayTabsRequest _payTabsRequest(Json intent) {
    final gatewayResponse = intent['payment_gateway_response'] as Json;
    return PayTabsRequest(
      checkoutUrl: gatewayResponse['redirect_url']?.toString() ?? '',
      returnUrlPrefix: AppConfig.hostUrl,
      transactionReference:
          gatewayResponse['tran_ref']?.toString() ?? intent['id'].toString(),
    );
  }

  static PayPalRequest _payPalRequest(Json intent) {
    final gatewayResponse = intent['payment_gateway_response'] as Json;
    final links = gatewayResponse['links'] as List<dynamic>? ?? [];
    final approveLink = links.cast<Json?>().firstWhere(
      (link) => link?['rel'] == 'approve',
      orElse: () => null,
    );

    return PayPalRequest(
      checkoutUrl: approveLink?['href']?.toString() ?? '',
      returnUrl: AppConfig.hostUrl,
      successPath: '/response/paypal/success',
      cancelPath: '/response/paypal/cancel',
      transactionReference:
          gatewayResponse['id']?.toString() ?? intent['id'].toString(),
    );
  }
}
