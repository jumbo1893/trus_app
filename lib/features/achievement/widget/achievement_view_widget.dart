import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/view/row_text_view_stream.dart';
import 'package:trus_app/features/achievement/widget/i_achievement_hash_key.dart';
import 'package:trus_app/features/achievement/widget/i_achievement_needed_fields.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';

class AchievementViewWidget<T> extends ConsumerWidget {
  final Size size;
  final IAchievementHashKey iAchievementHashKey;
  final ViewControllerMixin viewMixin;
  final IAchievementNeededFields iAchievementNeededFields;

  const AchievementViewWidget({
    Key? key,
    required this.size,
    required this.iAchievementHashKey,
    required this.viewMixin,
    required this.iAchievementNeededFields,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double padding = 8.0;
    return Column(
      children: [
        if (iAchievementNeededFields
            .isNeededToShowPlayerAchievementsFields()) ...[
          RowTextViewStream(
            key: const ValueKey('achievement_player_name_text'),
            size: size,
            textFieldText: "Hráč:",
            padding: padding,
            viewMixin: viewMixin,
            hashKey: iAchievementHashKey.playerName(),
          ),
        ],
        RowTextViewStream(
          key: const ValueKey('achievement_name_text'),
          size: size,
          textFieldText: "Název:",
          padding: padding,
          viewMixin: viewMixin,
          hashKey: iAchievementHashKey.nameKey(),
        ),
        const SizedBox(height: 10),
        RowTextViewStream(
          key: const ValueKey('achievement_description_text'),
          size: size,
          padding: padding,
          textFieldText: 'Popis:',
          viewMixin: viewMixin,
          hashKey: iAchievementHashKey.description(),
          allowWrap: true,
        ),
        const SizedBox(height: 10),
        if (iAchievementNeededFields.isNeededToShowSecondaryConditionField()) ...[
          RowTextViewStream(
            key: const ValueKey('achievement_condition_text'),
            size: size,
            padding: padding,
            textFieldText: "Podmínky:",
            viewMixin: viewMixin,
            hashKey: iAchievementHashKey.secondaryCondition(),
            allowWrap: true,
          ),
        ],
        if (iAchievementNeededFields
            .isNeededToShowPlayerAchievementsFields()) ...[
          RowTextViewStream(
            key: const ValueKey('achievement_accomplished_text'),
            size: size,
            padding: padding,
            textFieldText: "Splněno:",
            viewMixin: viewMixin,
            hashKey: iAchievementHashKey.accomplished(),
          ),
          if (iAchievementNeededFields.isNeededToShowMatchField()) ...[
            RowTextViewStream(
              key: const ValueKey('achievement_match_text'),
              size: size,
              padding: padding,
              textFieldText: "Splněno v zápase:",
              viewMixin: viewMixin,
              hashKey: iAchievementHashKey.match(),
              allowWrap: true,
            ),
          ],
          if (iAchievementNeededFields.isNeededToShowDetailField()) ...[
            RowTextViewStream(
              key: const ValueKey('achievement_detail_text'),
              size: size,
              padding: padding,
              textFieldText: "Detail:",
              viewMixin: viewMixin,
              hashKey: iAchievementHashKey.detail(),
              allowWrap: true,
            ),
          ],
        ],
        RowTextViewStream(
          key: const ValueKey('achievement_success_text'),
          size: size,
          padding: padding,
          textFieldText: "Úspěšnost:",
          viewMixin: viewMixin,
          hashKey: iAchievementHashKey.successRate(),
        ),
        if (iAchievementNeededFields.isNeededToShowPlayerListField()) ...[
          RowTextViewStream(
            key: const ValueKey('achievement_player_list_text'),
            size: size,
            padding: padding,
            textFieldText: "Splnili:",
            viewMixin: viewMixin,
            hashKey: iAchievementHashKey.playerList(),
          ),
        ],
      ],
    );
  }
}
