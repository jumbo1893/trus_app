import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';

mixin RestorableScrollMixin<T extends ConsumerStatefulWidget>
on ConsumerState<T> {
  final ScrollController scrollController = ScrollController();

  bool _scrollRestored = false;

  /// Každý screen pouze řekne, pod jakým klíčem se má scroll ukládat.
  String get scrollStorageKey;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_saveScrollOffset);
  }

  void _saveScrollOffset() {
    if (!scrollController.hasClients) {
      return;
    }

    ref.read(screenNotifierProvider.notifier).saveScrollOffset(
      scrollStorageKey,
      scrollController.offset,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_scrollRestored) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _scrollRestored || !scrollController.hasClients) {
        return;
      }

      final offset = ref
          .read(screenNotifierProvider.notifier)
          .getScrollOffset(scrollStorageKey);

      if (offset == null) {
        _scrollRestored = true;
        return;
      }

      scrollController.jumpTo(offset);
      _scrollRestored = true;
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_saveScrollOffset);
    scrollController.dispose();
    super.dispose();
  }
}