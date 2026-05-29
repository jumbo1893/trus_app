import 'package:flutter/material.dart';
import 'package:trus_app/models/api/receivedfine/stats/received_fine_stats_detail_models.dart';

import '../../../models/api/interfaces/model_to_string.dart';

sealed class UiEffect {
  const UiEffect();
}

class UiSnack extends UiEffect {
  final String message;
  final Duration duration;
  const UiSnack(this.message, {this.duration = const Duration(seconds: 1)});
}

class UiErrorDialog extends UiEffect {
  final String title;
  final String message;
  const UiErrorDialog(this.message, {this.title = "Chyba"});
}

class UiConfirmationDialog extends UiEffect {
  final String message;
  final VoidCallback continueCallBack;
  const UiConfirmationDialog(this.message, this.continueCallBack);
}

class UiConfirmationSheet extends UiEffect {
  final String message;
  final VoidCallback continueCallBack;
  const UiConfirmationSheet(this.message, this.continueCallBack);
}

class UiLoadingSheet extends UiEffect {
  final String? message;
  const UiLoadingSheet(this.message);
}

class UiHideLoadingSheet extends UiEffect {
  const UiHideLoadingSheet();
}

class UiSimpleSheet extends UiEffect {
  final String title;
  final String message;
  const UiSimpleSheet(this.title, this.message);
}

class UiStatsBottomSheet extends UiEffect {
  final String title;
  final String subtitle;
  final List<ModelToString> items;
  const UiStatsBottomSheet(this.title, this.subtitle, this.items);
}

class UiFineStatsBottomSheet extends UiEffect {
  final String title;
  final String subtitle;
  final ReceivedFineStatsDetailResponse response;
  const UiFineStatsBottomSheet(this.title, this.subtitle, this.response);
}