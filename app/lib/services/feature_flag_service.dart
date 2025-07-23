import 'dart:math';

import 'package:dio/dio.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/services/kv_service.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class FeatureFlagService {
  final KvService _kv = locator.get();
  final server = Posthog();
  final http = Dio();

  Future<void> init() async {
    final stopwatch = Stopwatch()..start();
    await server.reloadFeatureFlags();
    stopwatch.stop();
    print('reloadFeatureFlags took ${stopwatch.elapsedMilliseconds}ms');
  }

  Future<dynamic> get(String name) async {
    return await server.getFeatureFlagPayload(name);
  }

  Future<Map<String, dynamic>> appSoonflags() async {
    const apiKey = 'phc_yi3x5y6UV0b8ZsUuyzKGMlgDpJwMCo2eSsC9RxbaNEn';
    const url = 'https://eu.i.posthog.com/decide?v=3/';

    final response = await http.post(url, data: {
      'api_key': apiKey,
      'distinct_id': Random().nextInt(100).toString(),
    });

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final featureFlags = data['featureFlags'] as Map<String, dynamic>? ?? {};
      return featureFlags;
    } else {
      // Handle error, e.g., throw an exception or return an empty map
      throw Exception('Failed to load feature flags: ${response.statusCode}');
      // Or return {};
    }
  }
}
