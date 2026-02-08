import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/text_field_with_underline.dart';
import 'package:trus_app/features/achievement/screens/view_player_achievement_detail_screen.dart';
import 'package:trus_app/features/mixin/achievement_controller_mixin.dart';
import 'package:trus_app/models/api/achievement/achievement_player_detail.dart';

import '../../../../features/main/screen_controller.dart';
import '../../../../models/api/achievement/player_achievement_api_model.dart';
import '../../../utils/utils.dart';
import '../../loader.dart';

class AchievementViewStream extends ConsumerStatefulWidget {
  final Size size;
  final double padding;
  final AchievementControllerMixin achievementMixin;
  final String hashKey;

  const AchievementViewStream({
    required Key key,
    required this.size,
    required this.padding,
    required this.achievementMixin,
    required this.hashKey,
  }) : super(key: key);

  @override
  ConsumerState<AchievementViewStream> createState() => _AchievementViewStream();
}

class _AchievementViewStream extends ConsumerState<AchievementViewStream> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AchievementPlayerDetail>(
        stream: widget.achievementMixin.achievementPlayerValue(widget.hashKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          AchievementPlayerDetail achievementPlayerDetail = snapshot.data!;
          _titleController.text = "Splněno ${castDoubleToPercentage(achievementPlayerDetail.successRate)}% achievementů ${achievementPlayerDetail.accomplishedPlayerAchievements.length}/${achievementPlayerDetail.totalCount}";
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFieldWithUnderline(
                  key: ValueKey(
                      "${getValueFromValueKey(widget.key!)}_first_title"),
                  textController: _titleController,
                  align: TextAlign.center,
                ),
                _buildAchievementGrid(achievementPlayerDetail.accomplishedPlayerAchievements+achievementPlayerDetail.notAccomplishedPlayerAchievements),
                //_buildAchievementGrid(achievementPlayerDetail.notAccomplishedPlayerAchievements, Colors.grey),
              ],
            ),
          );
        });
  }

  Widget _buildAchievementGrid(List<PlayerAchievementApiModel> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 sloupce na šířku
        childAspectRatio: 1, // Čtvercové buňky
      ),
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return GestureDetector(
          onTap: () {
            ref
                .read(screenControllerProvider)
                .setPlayerAchievement(achievement);
            ref
                .read(screenControllerProvider)
                .changeFragment(ViewPlayerAchievementDetailScreen.id);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 6),
              Icon(Icons.emoji_events, size: 40, color: (achievement.accomplished == null || achievement.accomplished == false) ? Colors.grey : orangeColor),
              const SizedBox(height: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4), // Okraje
                  alignment: Alignment.topCenter, // Zarovnání textu nahoru
                  child: Text(
                    achievement.achievement.name,
                    textAlign: TextAlign.center,
                    maxLines: 3, // Omezíme na 3 řádky
                    overflow: TextOverflow.ellipsis, // Přidá "..." pokud je text dlouhý
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
