class PricingPlan {
  final String basePlanId;
  final String packageName;
  final String productId;
  final String offerId;
  final int freeTrailDuration;
  final int periodInDays;
  final double usdPrice;
  final bool isSubscription;

  PricingPlan({
    required this.basePlanId,
    required this.packageName,
    required this.productId,
    required this.offerId,
    required this.freeTrailDuration,
    required this.periodInDays,
    required this.usdPrice,
    required this.isSubscription,
  });

  factory PricingPlan.fromJson(Map<String, dynamic> json) {
    return PricingPlan(
      basePlanId: json['basePlanId'] as String,
      packageName: json['packageName'] as String,
      productId: json['productId'] as String,
      offerId: json['offerId'] as String,
      freeTrailDuration: json['freeTrailDuration'] as int,
      periodInDays: json['periodInDays'] as int,
      usdPrice: (json['usdPrice'] as num).toDouble(),
      isSubscription: json['isSubscription'] as bool,
    );
  }
}
