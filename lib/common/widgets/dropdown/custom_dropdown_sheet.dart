import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_state.dart';
import 'package:trus_app/models/api/interfaces/dropdown_item.dart';

import '../loader.dart';

class CustomDropdownSheet extends ConsumerWidget {
  final String hint;
  final String? error;
  final IDropdownState state;
  final IDropdownNotifier notifier;

  const CustomDropdownSheet({
    super.key,
    required this.hint,
    this.error,
    required this.state,
    required this.notifier,
  });

  void _openSelectionSheet(
      BuildContext context,
      List<DropdownItem> items,
      DropdownItem? selected,
      ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hint,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = selected == item;

                      return Material(
                        color: isSelected
                            ? Colors.orange.withAlpha(20)
                            : Colors.black.withAlpha(8),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            notifier.selectDropdown(item);
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.dropdownItem(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: Colors.black87,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: Colors.orange,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return state.getDropdownItems().when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: Loader()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (dropdownItems) {
        if (dropdownItems.isEmpty) {
          return const SizedBox.shrink();
        }

        final selected = state.getSelected();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hint,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 5),
            Material(
              color: Colors.black.withAlpha(8),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () =>
                    _openSelectionSheet(context, dropdownItems, selected),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          selected?.dropdownItem() ?? hint,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: selected != null
                                ? Colors.black87
                                : Colors.black45,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (error != null && error!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}