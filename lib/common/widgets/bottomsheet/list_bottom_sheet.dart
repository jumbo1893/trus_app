import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

typedef BottomSheetItemBuilder<T> = Widget Function(
    BuildContext context,
    T item,
    int index,
    );

class ListBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final BottomSheetItemBuilder<T> itemBuilder;
  final String emptyText;

  const ListBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.emptyText = 'Nejsou k dispozici žádná data.',
  });

  static Future<void> show<T>(
      BuildContext context, {
        required String title,
        required List<T> items,
        required BottomSheetItemBuilder<T> itemBuilder,
        String emptyText = 'Nejsou k dispozici žádná data.',
      }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ListBottomSheet<T>(
        title: title,
        items: items,
        itemBuilder: itemBuilder,
        emptyText: emptyText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppWidgetValues.cardShadow,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BottomSheetHandle(
                    color: colors.textMuted.withAlpha(60),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        emptyText,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 18,
                          thickness: 1,
                          color: colors.textMuted.withAlpha(30),
                        ),
                        itemBuilder: (context, index) {
                          return itemBuilder(
                            context,
                            items[index],
                            index,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetHandle extends StatelessWidget {
  final Color color;

  const _BottomSheetHandle({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}