import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/user/data/auth_service.dart';
import 'package:habitvote/features/user/data/models/user_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

enum AuthStatus { inside, out, checking }

class AuthState extends Equatable {
  final UserModel? user;
  final bool loginLoading;

  final AuthStatus status;

  const AuthState(
      {required this.user,
      this.loginLoading = false,
      this.status = AuthStatus.checking});

  copyWith({UserModel? user, bool? loginLoading, AuthStatus? status}) {
    return AuthState(
      user: user ?? this.user,
      loginLoading: loginLoading ?? this.loginLoading,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [user, loginLoading, status];
}

class AuthCubit extends Cubit<AuthState> {
  final _service = locator.get<AuthService>();

  AuthCubit() : super(AuthState(user: null));

  void init() async {
    final accessToken = await _service.fetch();

    if (accessToken == null) {
      emit(state.copyWith(status: AuthStatus.out));
    } else {
      emit(state.copyWith(
        status: AuthStatus.inside,
        user: UserModel.fromAccessToken(accessToken),
      ));
    }

    _service.currentAccessToken.listen((freshAccessToken) {
      if (freshAccessToken == null) {
        emit(state.copyWith(
          user: null,
          status: AuthStatus.out,
        ));
      } else {
        emit(state.copyWith(
          user: UserModel.fromAccessToken(freshAccessToken),
          status: AuthStatus.inside,
        ));
      }
    });

    unawaited(_service.fetch(live: true));
  }

  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);

    final user = change.nextState.user;
    if (user != null) {
      // Sentry.configureScope((scope) async {
      //   await scope.setUser(
      //     SentryUser(
      //         id: user.uid,
      //         segment: user.claims.grade,
      //         data: {"phone": user.phone}),
      //   );

      //   if (user.claims.isPremium) {
      //     await scope.setTag("premium", "true");
      //   }
      // });
    }
  }
}
