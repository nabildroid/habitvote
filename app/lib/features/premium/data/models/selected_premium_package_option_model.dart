import 'package:habitvote/features/premium/application/utils/payment_gatway_enum.dart';

class SelectedPremiumPackageOption {
  final String id;
  final PaymentGatway gateway;
  final int freeTrialDays;
  final String price;
  final String period;

  SelectedPremiumPackageOption({
    required this.id,
    required this.gateway,
    required this.freeTrialDays,
    required this.price,
    required this.period,
  });
}
