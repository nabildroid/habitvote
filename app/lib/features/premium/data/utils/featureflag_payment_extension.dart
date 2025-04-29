import 'package:habitvote/features/premium/application/utils/payment_gatway_enum.dart';
import 'package:habitvote/services/feature_flag_service.dart';

extension FeatureflagPaymentExtension on FeatureFlagService {
  Future<PaymentGatway> getPaymentGateway() async {
    final featureFlags = await appSoonflags();
    final paymentGateway = featureFlags['habitvote-purchaseGatway'] as String?;

    if (paymentGateway == 'stripe') {
      return PaymentGatway.stripe;
    } else if (paymentGateway == 'google') {
      return PaymentGatway.google;
    } else {
      return PaymentGatway.google; // Default value
    }
  }
}
