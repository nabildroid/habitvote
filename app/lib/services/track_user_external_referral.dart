import 'package:dio/dio.dart';
import 'dart:convert';

Future<Map<String, String>?> trackUserExternalReferral() async {
  try {
    final response = await Dio()
        .get("https://app-soon-ip-location.pni20156789.workers.dev/")
        .timeout(const Duration(seconds: 3));
    if (response.statusCode != 200) return null;

    final data = response.data as Map<String, dynamic>;
    final valueString = data['value'] as String?;

    if (valueString == null) {
      return null;
    }

    final decodedValue = jsonDecode(valueString) as Map;
    return Map<String, String>.from(decodedValue);
  } catch (e) {
    print("Error fetching external referral: $e");
    return null;
  }
}
