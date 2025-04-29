import 'package:habitvote/features/premium/application/utils/payment_gatway_enum.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:habitvote/features/premium/data/models/selected_premium_package_option_model.dart';

abstract class GooglePayUtils {
  /// Converts an ISO 8601 duration string (like P3M, P1Y, P7D) to an approximate number of days.
  static int convertPeriodToDays(String period) {
    final RegExp regex = RegExp(r'P(\d+)([YWMD])');
    final Match? match = regex.firstMatch(period);

    if (match != null && match.groupCount == 2) {
      try {
        final int value = int.parse(match.group(1)!);
        final String unit = match.group(2)!;

        switch (unit) {
          case 'Y':
            return value * 365; // Approximate years to days
          case 'M':
            return value * 30; // Approximate months to days
          case 'W':
            return value * 7; // Approximate months to days
          case 'D':
            return value; // Days
          default:
            return 0; // Unknown unit
        }
      } catch (e) {
        // Handle potential parsing error, though regex should prevent it
        return 0;
      }
    }
    return 0; // Pattern not matched
  }

  static List<SelectedPremiumPackageOption> getPackagesFromProductDetails(
      List<GooglePlayProductDetails> products) {
    if (products.isEmpty) return [];

    final parent = products.first;
    if (parent.productDetails.subscriptionOfferDetails == null ||
        parent.productDetails.subscriptionOfferDetails!.isEmpty) {
      return [];
    }

    final offers = parent.productDetails.subscriptionOfferDetails!;

    final packages = offers.map((offer) {
      final freePhase = offer.pricingPhases
          .where((f) => f.formattedPrice == "Free")
          .firstOrNull;
      final secondPhase = offer.pricingPhases
          .where((f) => f.formattedPrice != "Free")
          .firstOrNull;

      return SelectedPremiumPackageOption(
          id: offer.offerIdToken,
          freeTrialDays: freePhase == null
              ? 0
              : convertPeriodToDays(freePhase.billingPeriod),
          gateway: PaymentGatway.google,
          period: secondPhase == null
              ? "Loading"
              : convertPeriodToDays(secondPhase.billingPeriod) > 30
                  ? "Year"
                  : "Month",
          price: secondPhase?.formattedPrice ?? "0\$");
    }).toList();

    // remove packages that doesn't have free trials for benifit for thier children offers (offer free trial)
    packages.removeWhere((package) => packages.any(
          (test) =>
              test.period == package.period &&
              package.id != test.id &&
              package.freeTrialDays < test.freeTrialDays,
        ));

    return packages;
  }
}
