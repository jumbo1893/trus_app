

import 'package:flutter/material.dart';
import 'package:trus_app/features/general/state/loading_error_state.dart';

@immutable
class BaseCrudState<T> extends ErrorState {
  final T? model;

  const BaseCrudState({
    this.model,
    super.errors,
  });

  @override
  BaseCrudState<T> copyWith({
    T? model,
    Map<String, String>? errors,
  }) {
    return BaseCrudState<T>(
      model: model ?? this.model,
      errors: errors ?? this.errors,
    );
  }
}

