import 'dart:async';
import 'dart:math';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/premium/application/utils/payment_gatway_enum.dart';
import 'package:habitvote/features/premium/data/models/pricing_plan.dart';
import 'package:habitvote/features/premium/data/models/selected_premium_package_option_model.dart';
import 'package:habitvote/features/premium/data/repository/payment_repository.dart';
import 'package:habitvote/features/premium/data/utils/featureflag_payment_extension.dart';
import 'package:habitvote/features/user/application/cubits/auth_cubit.dart';
import 'package:habitvote/features/user/data/auth_service.dart';
import 'package:habitvote/features/user/data/models/user_model.dart';
import 'package:habitvote/services/feature_flag_service.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:habitvote/shared/wait_two_futures.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rxdart/rxdart.dart';

class PremiumState extends Equatable {
  final SelectedPremiumPackageOption? selectedPackage;

  final bool loadingWebviews;
  final bool loadingPircing;

  final List<PricingPlan>? pricing;
  final List<ProductDetails>? products;

  final PaymentGatway paymentGatway;

  final bool checkingNewPruchase;
  final bool isNewPurchased;

  PremiumState({
    this.selectedPackage,
    this.loadingWebviews = false,
    this.loadingPircing = false,
    this.paymentGatway = PaymentGatway.google,
    this.pricing,
    this.products,
    this.checkingNewPruchase = false,
    this.isNewPurchased = false,
  });

  PremiumState copyWith({
    SelectedPremiumPackageOption? selectedPackage,
    bool? loadingWebviews,
    PaymentGatway? paymentGatway,
    bool? loadingPircing,
    List<PricingPlan>? pircing,
    List<ProductDetails>? products,
    bool? checkingNewPruchase,
    bool? isNewPurchased,
  }) {
    return PremiumState(
      selectedPackage: selectedPackage ?? this.selectedPackage,
      loadingWebviews: loadingWebviews ?? this.loadingWebviews,
      paymentGatway: paymentGatway ?? this.paymentGatway,
      loadingPircing: loadingPircing ?? this.loadingPircing,
      pricing: pircing ?? this.pricing,
      products: products ?? this.products,
      checkingNewPruchase: checkingNewPruchase ?? this.checkingNewPruchase,
      isNewPurchased: isNewPurchased ?? this.isNewPurchased,
    );
  }

  @override
  List<Object?> get props => [
        selectedPackage,
        loadingWebviews,
        paymentGatway,
        loadingPircing,
        pricing,
        products,
        checkingNewPruchase,
        isNewPurchased,
      ];
}

class PremiumCubit extends Cubit<PremiumState> {
  late String userid;
  PremiumCubit() : super(PremiumState());

  final _listeners = CompositeSubscription();

  void setSelecedPackage(SelectedPremiumPackageOption package) {
    emit(state.copyWith(selectedPackage: package));
  }

  void selectStripeOffer(String id) {
    final selected = state.pricing!.firstWhere(
        (element) => element.offerId == id || element.basePlanId == id);

    setSelecedPackage(SelectedPremiumPackageOption(
      id: selected.offerId,
      freeTrialDays: selected.freeTrailDuration,
      gateway: PaymentGatway.stripe,
      price: "\$${selected.usdPrice}",
      period: selected.periodInDays > 30 ? "Year" : "Month",
    ));

    initStripePayment();
  }

  void handleStripeSuccess() async {
    // final userRepo = locator.get<UserRepository>();

    // userRepo.currentUser.value = userRepo.currentUser.value!.makeItPro();
    // emit(state.copyWith(isNewPurchased: true));

    // await userRepo.getUser(live: true);
  }

  void purchaseFromGoogle() async {
    final package = state.selectedPackage;
    if (package == null) return;
    if (package.gateway != PaymentGatway.google) return;

    final product = state.products!
        .where((e) => (e as GooglePlayProductDetails).offerToken == package.id);

    if (product.isEmpty) return;

    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: product.first,
      ),
    );
  }

  Stream<List<PurchaseDetails>> getPurchaseStream() {
    return InAppPurchase.instance.purchaseStream.where((purchaseDetailsList) {
      if (purchaseDetailsList.isEmpty) return false;
      final purchaseDetails = purchaseDetailsList.first;

      return purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored ||
          purchaseDetails.pendingCompletePurchase;
    });
  }

  StreamSubscription? _inAppPurchaseSub;
  void init(UserModel user) async {
    userid = user.uid;
    _inAppPurchaseSub?.cancel();

    _inAppPurchaseSub = getPurchaseStream().listen((purchaseDetailsList) async {
      final purchaseDetails = purchaseDetailsList.first;

      emit(state.copyWith(checkingNewPruchase: true));

      final googleToken =
          purchaseDetails.verificationData.serverVerificationData;
      await locator
          .get<PaymentRepo>()
          .verifyGooglePayment(googleToken: googleToken, uid: user.uid);

      locator.get<AuthService>().fetch(live: true);
      await InAppPurchase.instance.completePurchase(purchaseDetails);

      emit(state.copyWith(checkingNewPruchase: false, isNewPurchased: true));
    });
  }

  bool isStripeCheckoutInited = false;

  initStripePayment({bool force = false}) async {
    if (isStripeCheckoutInited && !force) return;
    isStripeCheckoutInited = true;

    emit(state.copyWith(loadingWebviews: true));
    final repo = locator.get<PaymentRepo>();

    final gatwayEntries = await Future.wait(state.pricing!.map((p) async {
      final key = p.offerId.isEmpty ? p.basePlanId : p.offerId;
      return MapEntry(
          key,
          await repo.getStripeLink(
            productId: key,
            uid: userid,
          ));
    }));

    await createHeadlessStripeWebviews(gatwayEntries);
  }

  Map<String, HeadlessInAppWebView> headlessStripes = {};
  Future<void> createHeadlessStripeWebviews(
      List<MapEntry<String, String>> entries) async {
    int i = entries.length;
    for (var entry in entries) {
      final key = entry.key;
      final url = entry.value;

      if (headlessStripes[key] != null) {
        await headlessStripes[key]!.dispose();
        headlessStripes.remove(key);
      }

      headlessStripes[key] = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(),
        onLoadStart: (_, __) {
          // sometime trying multiple time for debug perpos block the experience
          if (kDebugMode && --i == 0) {
            emit(state.copyWith(loadingWebviews: false));
          }
        },
        onLoadStop: (_, __) {
          if (kReleaseMode && --i == 0) {
            emit(state.copyWith(loadingWebviews: false));
          }
        },
      );
      Future.delayed(Duration(milliseconds: 100));
      await headlessStripes[key]!.run();
    }
  }

  @override
  Future<void> close() {
    _listeners.cancel();
    _inAppPurchaseSub?.cancel();

    for (var v in headlessStripes.values) {
      v.dispose();
    }
    return super.close();
  }

  Future<void> loadOffers() async {
    emit(state.copyWith(loadingPircing: true));

    final productsFuture = InAppPurchase.instance
        .queryProductDetails({"me.laknabil.habitvote.premium"}).catchError(
            (e) => ProductDetailsResponse(
                error: e, productDetails: [], notFoundIDs: []));

    final promises = await waitForTwo(
      locator.get<PaymentRepo>().getPircing(),
      productsFuture,
    );

    emit(state.copyWith(
      loadingPircing: false,
      pircing: promises.key,
      products: promises.value.productDetails,
    ));
  }

  decidePayment(UserModel user) async {
    final features = locator.get<FeatureFlagService>();

    final isGoogleAvialable = await InAppPurchase.instance.isAvailable();

    if (isGoogleAvialable) {
      final paymentGatway = await features.getPaymentGateway();
      emit(state.copyWith(paymentGatway: paymentGatway));
    } else {
      emit(state.copyWith(paymentGatway: PaymentGatway.stripe));
    }
  }
}

extension PremiumCubitExtention on PremiumCubit {
  sync(BuildContext context) async {
    final userStream = context
        .read<AuthCubit>()
        .stream
        .map((e) => e.user)
        .distinct()
        .whereNotNull();

    _listeners.add(userStream.listen((user) {
      init(user);

      if (!user.claims.isTrulyPremium) {
        decidePayment(user);
        loadOffers();
      }
    }));
  }
}
