import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/features/user/application/cubits/auth_cubit.dart';

extension IsproContextExtension on BuildContext {
  isPro() {
    return this.read<AuthCubit>().state.user?.claims.isTrulyPremium == true;
  }

  watchIsPro() {
    return this.watch<AuthCubit>().state.user?.claims.isTrulyPremium == true;
  }
}
