import 'dart:io';

import 'package:flutter_native_splash/flutter_native_splash.dart';

void removeSplashScreen(Duration? duration) {
  if (!Platform.isAndroid) return;

  Future.delayed(duration ?? Duration.zero, () {
    FlutterNativeSplash.remove();
  });
}
