import 'package:eClassify/features/subscription/models/payment_gateway.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class PaymentRepository {
  PaymentRepository._internal();

  static final PaymentRepository _instance = PaymentRepository._internal();

  static PaymentRepository get instance => _instance;

  /// Fetches the payment gateways enabled by the backend. The API only
  /// returns entries for enabled gateways, so presence in the response is
  /// itself the "enabled" signal — no separate status filtering needed.
  Future<List<PaymentGateway>> getPaymentGateways() async {
    final result = await Api.get(url: ApiEndpoints.getPaymentSettings);
    final data = (result['data'] ?? {}) as Json;

    return data.entries
        .map((entry) => _gatewayFromEntry(entry.key, entry.value as Json))
        .whereType<PaymentGateway>()
        .toList();
  }

  PaymentGateway? _gatewayFromEntry(String key, Json value) {
    return switch (key) {
      'Stripe' => StripeGateway(apiKey: value[ApiParams.apiKey]?.toString() ?? ''),
      'Razorpay' => RazorpayGateway(
        apiKey: value[ApiParams.apiKey]?.toString() ?? '',
      ),
      'PhonePe' => const PhonePeGateway(),
      'Paystack' => const PaystackGateway(),
      'flutterwave' => const FlutterwaveGateway(),
      'Paypal' => const PayPalGateway(),
      'DPO' => const DpoGateway(),
      'Paytabs' => const PayTabsGateway(),
      'bankTransfer' => BankTransferGateway(
        details: BankTransferDetails.fromJson(value),
      ),
      _ => null,
    };
  }

  Future<Json> getPaymentIntent({
    required int packageId,
    required String paymentMethod,
  }) async {
    final response = await Api.post(
      url: ApiEndpoints.getPaymentIntent,
      parameter: {
        ApiParams.packageId: packageId,
        ApiParams.paymentMethod: paymentMethod,
        if (paymentMethod case == "Paystack" || "PhonePe" || "PayPal")
          ApiParams.platformType: "app",
      },
    );
    return response;
  }

  Future<void> makePaymentTransactionFail({
    required int paymentTransactionId,
  }) async {
    await Api.post(
      url: ApiEndpoints.makePaymentTransactionFail,
      parameter: {ApiParams.paymentTransactionId: paymentTransactionId},
    );
  }
}
