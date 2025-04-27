import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:habitvote/core/constant.dart';

abstract class AuthorizedDio {
  static final defaultHttp = Dio(BaseOptions(
    baseUrl: "http://192.168.0.105:3000",
  ));

  final Dio rawHttp;
  final completerhttp = Completer<Dio>();

  Future<Dio> get http => completerhttp.future;

  AuthorizedDio({required this.rawHttp});
}
