import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/view/achievement_view_stream.dart';
import 'package:trus_app/common/widgets/rows/view/row_text_view_stream.dart';
import 'package:trus_app/features/mixin/achievement_controller_mixin.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';
import 'package:trus_app/features/player/widget/i_player_hash_key.dart';

class PlayerViewWidget<T> extends ConsumerWidget {
  final Size size;
  final IPlayerHashKey iPlayerHashKey;
  final ViewControllerMixin viewMixin;
  final AchievementControllerMixin achievementMixin;
  final String nameFieldText;

  const PlayerViewWidget({
    Key? key,
    required this.size,
    required this.iPlayerHashKey,
    required this.viewMixin,
    required this.achievementMixin,
    required this.nameFieldText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double padding = 8.0;
    return Column(
      children: [
        RowTextViewStream(
          key: const ValueKey('player_name_text'),
          size: size,
          textFieldText: nameFieldText,
          padding: padding,
          viewMixin: viewMixin,
          hashKey: iPlayerHashKey.nameKey(),
        ),
        const SizedBox(height: 10),
        RowTextViewStream(
          key: const ValueKey('player_footballer_text'),
          size: size,
          padding: padding,
          textFieldText: 'Jméno hráče:',
          viewMixin: viewMixin,
          hashKey: iPlayerHashKey.footballerKey(),
        ),
        const SizedBox(height: 10),
        RowTextViewStream(
          key: const ValueKey('player_date_text'),
          size: size,
          padding: padding,
          textFieldText: "Datum narození:",
          viewMixin: viewMixin,
          hashKey: iPlayerHashKey.dateKey(),
        ),
        RowTextViewStream(
          key: const ValueKey('player_detail_text'),
          size: size,
          padding: padding,
          textFieldText: "Statistiky:",
          viewMixin: viewMixin,
          hashKey: iPlayerHashKey.footballerDetailKey(),
        ),
        AchievementViewStream(
          key: const ValueKey('player_achievement'),
          size: size,
          padding: padding,
          achievementMixin: achievementMixin,
          hashKey: iPlayerHashKey.achievementsKey(),
        ),
      ],
    );
  }
}
