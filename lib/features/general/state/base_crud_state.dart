

import 'package:flutter/material.dart';
import 'package:trus_app/features/general/state/loading_error_state.dart';

import '../../../common/widgets/notifier/loader/loading_state.dart';

@immutable
class BaseCrudState<T> extends LoadingErrorState {
  final T? model;

  const BaseCrudState({
    this.model,
    super.loading,
    super.errors,
    super.successMessage,
  });

  @override
  BaseCrudState<T> copyWith({
    T? model,
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  }) {
    return BaseCrudState<T>(
      model: model ?? this.model,
      loading: loading ?? this.loading,
      errors: errors ?? this.errors,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

