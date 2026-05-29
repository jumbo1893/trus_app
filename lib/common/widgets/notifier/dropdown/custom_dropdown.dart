import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_state.dart';
import 'package:trus_app/models/api/interfaces/dropdown_item.dart';

import '../../loader.dart';

class CustomDropdown extends ConsumerWidget {
  final String hint;
  final String? error;
  final IDropdownState state;
  final IDropdownNotifier notifier;

  const CustomDropdown({
    Key? key,
    required this.hint,
    this.error,
    required this.state,
    required this.notifier,
  }) : super(key: key);

  List<DropdownMenuItem<DropdownItem>> _buildItems(
      BuildContext context,
      List<DropdownItem> dropdownItems,
      ) {
    return dropdownItems.map((item) {
      return DropdownMenuItem<DropdownItem>(
        value: item,
        child: Text(
          item.dropdownItem(),
          style: TextStyle(
            fontSize: 12,
            color: context.appColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          softWrap: true,
          maxLines: 3,
          overflow: TextOverflow.visible,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return state.getDropdownItems().when(
      loading: () => const SizedBox(
        height: 42,
        child: Center(child: Loader()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (dropdownItems) {
        if (dropdownItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hint,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.appColors.shadow.withAlpha(8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<DropdownItem>(
                  isExpanded: true,
                  value: state.getSelected(),
                  hint: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.appColors.textMuted,
                    ),
                  ),
                  items: _buildItems(context, dropdownItems),
                  onChanged: (item) {
                    if (item != null) {
                      notifier.selectDropdown(item);
                    }
                  },
                  iconStyleData: IconStyleData(
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  buttonStyleData: const ButtonStyleData(
                    height: 42,
                    width: double.infinity,
                    padding: EdgeInsets.zero,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 260,
                    elevation: 6,
                    decoration: BoxDecoration(
                      color: context.appColors.cardBackground,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    offset: const Offset(0, 6),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),
            if (error != null && error!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                error!,
                style: TextStyle(
                  color: context.appColors.errorSolid,
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