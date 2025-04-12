import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/view/row_text_view_stream.dart';
import 'package:trus_app/features/football/widget/i_football_match_detail_hash_key.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';

class FootballMatchDetailViewWidget<T> extends ConsumerWidget {
  final Size size;
  final ViewControllerMixin viewMixin;
  final IFootballMatchDetailHashKey iFootballMatchDetailHashKey;

  const FootballMatchDetailViewWidget({
    Key? key,
    required this.size,
    required this.viewMixin,
    required this.iFootballMatchDetailHashKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double padding = 8.0;
    return Column(
      children: [
        RowTextViewStream(
          key: const ValueKey('football_match_name_text'),
          size: size,
          textFieldText: "Zápas:",
          padding: padding,
          viewMixin: viewMixin,
          hashKey: iFootballMatchDetailHashKey.matchName(),
          allowWrap: true,
        ),
        RowTextViewStream(
          key: const ValueKey('football_match_round_text'),
          size: size,
          textFieldText: "Kolo:",
          padding: padding,
          viewMixin: viewMixin,
          hashKey: iFootballMatchDetailHashKey.dateAndLeague(),
          allowWrap: true,
        ),
        const SizedBox(height: 10),
        RowTextViewStream(
          key: const ValueKey('football_match_stadium_text'),
          size: size,
          padding: padding,
          textFieldText: 'Stadion:',
          viewMixin: viewMixin,
          hashKey: iFootballMatchDetailHashKey.stadium(),
          allowWrap: true,
        ),
        const SizedBox(height: 10),
        RowTextViewStream(
          key: const ValueKey('football_match_referee_text'),
          size: size,
          padding: padding,
          textFieldText: "Rozhodčí:",
          viewMixin: viewMixin,
          hashKey: iFootballMatchDetailHashKey.referee(),
          allowWrap: true,
        ),
        RowTextViewStream(
          key: const ValueKey('football_match_referee_comment_text'),
          size: size,
          padding: padding,
          textFieldText: "Komentář:",
          viewMixin: viewMixin,
          hashKey: iFootballMatchDetailHashKey.refereeComment(),
          allowWrap: true,
        ),
      ],
    );
  }
}
