import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_widget_values.dart';
import '../../loader.dart';

typedef ModelToStringItemBuilder = Widget Function(
    BuildContext context,
    dynamic item,
    VoidCallback? onTap,
    int index,
    int itemCount,
    );

class ModelToStringListview extends ConsumerStatefulWidget {
  final IListviewState state;
  final IListviewNotifier? notifier;
  final String emptyListText;
  final String emptyListTitle;
  final String? storageKey;
  final ScrollController? scrollController;
  final ModelToStringItemBuilder? itemBuilder;

  const ModelToStringListview({
    super.key,
    required this.state,
    required this.notifier,
    this.emptyListText = "Zatím tu nic není",
    this.emptyListTitle = "Po změně sezony se záznamy objeví zde",
    this.storageKey,
    this.scrollController,
    this.itemBuilder,
  }) : assert(
  storageKey == null || scrollController == null,
  'Použij buď storageKey, nebo scrollController, ne obojí současně.',
  );

  @override
  ConsumerState<ModelToStringListview> createState() =>
      _ModelToStringListviewState();
}

class _ModelToStringListviewState
    extends ConsumerState<ModelToStringListview> {
  late final ScrollController _internalScrollController;

  bool _scrollRestored = false;

  ScrollController get _controller =>
      widget.scrollController ?? _internalScrollController;

  bool get _managesScrollRestoration => widget.storageKey != null;

  @override
  void initState() {
    super.initState();

    _internalScrollController = ScrollController();

    if (_managesScrollRestoration) {
      _controller.addListener(_saveScrollOffset);
    }
  }

  @override
  void didUpdateWidget(covariant ModelToStringListview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.storageKey == widget.storageKey) {
      return;
    }

    if (oldWidget.storageKey != null) {
      _controller.removeListener(_saveScrollOffset);
    }

    _scrollRestored = false;

    if (_managesScrollRestoration) {
      _controller.addListener(_saveScrollOffset);
    }
  }

  void _saveScrollOffset() {
    if (!_managesScrollRestoration || !_controller.hasClients) {
      return;
    }

    ref.read(screenNotifierProvider.notifier).saveScrollOffset(
      widget.storageKey!,
      _controller.offset,
    );
  }

  void _restoreScrollOffsetIfNeeded() {
    if (!_managesScrollRestoration || _scrollRestored) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _scrollRestored || !_controller.hasClients) {
        return;
      }

      final savedOffset = ref
          .read(screenNotifierProvider.notifier)
          .getScrollOffset(widget.storageKey!);

      if (savedOffset != null) {
        final maxOffset = _controller.position.maxScrollExtent;

        _controller.jumpTo(
          savedOffset.clamp(0.0, maxOffset).toDouble(),
        );
      }

      _scrollRestored = true;
    });
  }

  @override
  void dispose() {
    if (_managesScrollRestoration) {
      _controller.removeListener(_saveScrollOffset);
    }

    _internalScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.state.getListViewItems().when(
      loading: () => const Center(
        child: Loader(),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (modelList) {
        if (modelList.isEmpty) {
          return _EmptyListState(
            title: widget.emptyListTitle,
            text: widget.emptyListText,
          );
        }

        _restoreScrollOffsetIfNeeded();

        return ListView.separated(
          controller: _controller,
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: modelList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = modelList[index];

            final onTap = widget.notifier == null
                ? null
                : () => widget.notifier!.selectListviewItem(item);

            if (widget.itemBuilder != null) {
              return widget.itemBuilder!(
                context,
                item,
                onTap,
                index,
                modelList.length,
              );
            }

            return _DefaultModelListTile(
              item: item,
              onTap: onTap,
            );
          },
        );
      },
    );
  }
}

class _EmptyListState extends StatelessWidget {
  final String title;
  final String text;

  const _EmptyListState({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: AppWidgetValues.borderRadiusXl,
            boxShadow: AppWidgetValues.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 36,
                color: context.appColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultModelListTile extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;

  const _DefaultModelListTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.cardBackground,
      borderRadius: AppWidgetValues.borderRadiusXl,
      child: InkWell(
        borderRadius: AppWidgetValues.borderRadiusXl,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: AppWidgetValues.borderRadiusXl,
            boxShadow: AppWidgetValues.cardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.listViewTitle(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        height: 1.3,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.toStringForListView(),
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: context.appColors.textSecondary,
                    size: 22,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}