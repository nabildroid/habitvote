import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/premium/data/models/pricing_plan.dart';
import 'package:habitvote/features/user/data/auth_service.dart';

class PaymentRepo {
  final auth = locator.get<AuthService>();

  Future<List<PricingPlan>> getPircing() async {
    final reponse = await auth.http.get("/payment/pricing");

    if (reponse.statusCode != 200) {
      throw Exception("Error getting pricing");
    }

    final List<dynamic> data = reponse.data['offers'] as List<dynamic>;
    final List<PricingPlan> pricingPlans = data
        .map((e) => PricingPlan.fromJson(e as Map<String, dynamic>))
        .toList();
    return pricingPlans;
  }

  Future<String> getStripeLink(
      {required String productId, required String uid}) async {
    final link = "${auth.http.options.baseUrl}/payment/$uid}/$productId";
    return link;
  }

  Future<void> verifyGooglePayment(
      {required String googleToken, required String uid}) async {
    final response = await auth.http.post(
      "/payment/purchase/google-play/verify/$uid",
      data: {
        "serverToken": googleToken,
      },
    );

    print(response);
  }
}
