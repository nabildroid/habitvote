import 'package:flutter/material.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/onboarding/data/welcome_variations.dart';
import 'package:habitvote/features/onboarding/presentration/screens/onboarding_screen.dart';
import 'package:habitvote/services/feature_flag_service.dart';
import 'package:habitvote/services/track_user_external_referral.dart';
import 'package:habitvote/shared/utils.dart';
import 'package:habitvote/shared/widgets/brilliant_ok_button.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  WelcomeScreenVariation? variation;

  @override
  void initState() {
    super.initState();

    fetchRefferal().then((tag) {
      fetchVariation(tag);
    });
  }

  Future<String?> fetchRefferal() async {
    final data = await trackUserExternalReferral();

    if (data == null) {
      return null;
    }

    Posthog().capture(
      eventName: 'found_external_source',
      properties: {
        ...data,
      },
    );

    return data["extra"] != null && data["extra"]!.isNotEmpty
        ? data["extra"]
        : null;
  }

  void fetchVariation(String? tag) async {
    try {
      final variationPayload = await locator
          .get<FeatureFlagService>()
          .get(tag ?? "welcome-screen-3-items-title")
          .timeout(const Duration(seconds: 2));

      if (variationPayload != null) {
        variation = WelcomeScreenVariation.fromJson(variationPayload);
      }
    } catch (e) {}
    variation ??= WelcomeScreenVariation.defaultVariation();

    setState(() {});
    removeSplashScreen(Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    if (variation == null) {
      return Scaffold(
        backgroundColor: const Color(0xff1C1C1D),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }
    return _WelcomeScreen(
      variation: variation!,
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  final WelcomeScreenVariation variation;
  const _WelcomeScreen({
    super.key,
    required this.variation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1C1C1D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Text(
                  variation.title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 60),
                ...variation.features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: _FeatureItem(
                      icon: feature.icon,
                      iconColor: const Color(0xffBAFD4F),
                      title: feature.title,
                      subtitle: feature.subtitle,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: BrilliantOkButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                );
              },
              text: "Continue",
              tag: "continue",
            ),
          ),
        )
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 36),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
