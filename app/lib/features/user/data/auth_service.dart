import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/core/network/authorized_dio.dart';
import 'package:habitvote/features/user/data/models/access_token_model.dart';
import 'package:habitvote/services/kv_service.dart';
import 'package:rxdart/rxdart.dart';

// ignore: constant_identifier_names
const _BaseURL = kReleaseMode
    ? "https://vocafusion-auth.pni20156789.workers.dev"
    : "http://192.168.0.105:8787";
// ignore: constant_identifier_names
const _AUTH_HEADER = "x-auth";
// ignore: constant_identifier_names
const _TOKEN_REFRESH_BUFFER_SECONDS = 60; // 1 minute before expiration
// ignore: constant_identifier_names
const _TOKEN_CHECK_INTERVAL_SECONDS = 30; // Check every 30 seconds

class AuthService {
  final Dio http = Dio(BaseOptions(baseUrl: _BaseURL));
  final tokenSteam = BehaviorSubject<String?>()..add(null);
  final currentAccessToken = BehaviorSubject<AccessTokenModel?>();
  final kv = locator.get<KvService>();

  Timer? _tokenRefreshTimer;

  AuthService() {
    // Initialize token refresh mechanism
    _setupTokenRefreshTimer();
  }

  void _setupTokenRefreshTimer() {
    // Cancel any existing timer
    _tokenRefreshTimer?.cancel();

    // Set up a periodic timer to check token expiration
    _tokenRefreshTimer = Timer.periodic(
        Duration(seconds: _TOKEN_CHECK_INTERVAL_SECONDS),
        (_) => _checkTokenExpiration());
  }

  Future<void> _checkTokenExpiration() async {
    final accessToken = await kv.getAccessToken();
    if (accessToken == null) return;

    if (_shouldRefreshToken(accessToken)) {
      print("Token will expire soon, refreshing...");
      try {
        final freshAccessToken = await _refreshToken(accessToken);
        _saveAccessToken(freshAccessToken);
      } catch (e) {
        print("Error refreshing token: $e");
      }
    }
  }

  bool _shouldRefreshToken(AccessTokenModel accessToken) {
    final now = DateTime.now();
    final expiresIn = accessToken.expires.difference(now).inSeconds;
    return expiresIn <= _TOKEN_REFRESH_BUFFER_SECONDS;
  }

  Future<AccessTokenModel> _refreshToken(AccessTokenModel accessToken) async {
    final response = await http.post(
      "/refresh",
      data: {"token": accessToken.refreshToken},
    );

    return accessToken.refresh(response.data["newToken"]);
  }

  void _saveAccessToken(AccessTokenModel accessToken) {
    http.interceptors.clear();
    http.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers[_AUTH_HEADER] = accessToken.token;
        handler.next(options);
      },
    ));
    kv.setAccessToken(accessToken);
    tokenSteam.add(accessToken.token);
    currentAccessToken.add(accessToken);
  }

  Future<AccessTokenModel?> fetch({bool live = false}) async {
    final accessToken = await kv.getAccessToken();
    if (accessToken == null) return null;

    if (accessToken.isExpired || _shouldRefreshToken(accessToken) || live) {
      print("going to refresh the access token");

      final promise = _refreshToken(accessToken).then((freshAccessToken) {
        _saveAccessToken(freshAccessToken);
        return freshAccessToken;
      });

      if (live) return promise;
      unawaited(promise);
    } else {
      _saveAccessToken(accessToken);
    }

    return accessToken;
  }

  void subscribeToToken(AuthorizedDio customDio) {
    tokenSteam.listen((token) {
      if (token == null) return;

      customDio.rawHttp.interceptors.clear();
      customDio.rawHttp.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers[_AUTH_HEADER] = tokenSteam.value;
          handler.next(options);
        },
      ));

      if (customDio.completerhttp.isCompleted) return;
      customDio.completerhttp.complete(customDio.rawHttp);
    });
  }

  void dispose() {
    _tokenRefreshTimer?.cancel();
    tokenSteam.close();
  }

  String get logIdentifier => "Auth-service";
}

extension AuthProviders on AuthService {
  Future<AccessTokenModel?> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn(scopes: []);
    try {
      final authUser = await googleSignIn.signIn();
      final googleAccessToken = (await authUser?.authentication)?.accessToken;

      final response = await http.post("/loginWithGoogle", data: {
        "accessToken": googleAccessToken,
      });

      final accessToken = AccessTokenModel(
        expires: DateTime.fromMillisecondsSinceEpoch(
            response.data["expires"] * 1000),
        refreshToken: response.data["refreshToken"],
        token: response.data["token"],
      );
      _saveAccessToken(accessToken);

      return accessToken;
    } catch (error) {
      print(error);
    }

    return null;
  }

  Future<AccessTokenModel?> anonymousLogin() async {
    final googleSignIn = GoogleSignIn(scopes: []);
    try {
      final response = await http.post("/anonymous");

      final accessToken = AccessTokenModel(
        expires: DateTime.fromMillisecondsSinceEpoch(
            response.data["expires"] * 1000),
        refreshToken: response.data["refreshToken"],
        token: response.data["token"],
      );
      _saveAccessToken(accessToken);

      return accessToken;
    } catch (error) {
      print(error);
    }

    return null;
  }
}

extension on KvService {
  Future<AccessTokenModel?> getAccessToken() async {
    final data = await getString("accessToken");
    if (data == null) return null;

    return AccessTokenModel.fromJson(data);
  }

  Future<void> setAccessToken(AccessTokenModel accessToken) async {
    await setString(
      "accessToken",
      accessToken.toJson(),
    );
  }
}
