import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/core/cubits/app_cubit.dart';
import 'package:habitvote/features/vote/application/votes_cubit.dart';

extension AppContextExtension on BuildContext {
  AppCubit get appCubit => read<AppCubit>();
  AppState get appState => read<AppCubit>().state;
  AppState get watchAppState => watch<AppCubit>().state;
}
