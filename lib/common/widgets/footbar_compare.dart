import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_state.dart';
import 'package:trus_app/features/footbar/controller/footbar_compare_notifier.dart';
import 'package:trus_app/features/footbar/state/footbar_compare_state.dart';
import 'package:trus_app/models/api/footbar/footbar_session.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

import '../../models/api/interfaces/dropdown_item.dart';
import 'notifier/dropdown/custom_dropdown.dart';
import 'notifier/dropdown/i_dropdown_notifier.dart';

class FootbarCompare extends ConsumerWidget {
  const FootbarCompare({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(footbarCompareNotifierProvider.notifier);
    final state = ref.watch(footbarCompareNotifierProvider);

    final leftPlayerState = PlayerDropdownState(state, isLeft: true);
    final rightPlayerState = PlayerDropdownState(state, isLeft: false);

    final leftPlayerNotifier = PlayerDropdownNotifier(notifier, isLeft: true);
    final rightPlayerNotifier = PlayerDropdownNotifier(notifier, isLeft: false);

    if (state.leftSession == null) {
      return const _FootbarEmptyState();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _PlayerSelectCard(
            leftPlayerState: leftPlayerState,
            rightPlayerState: rightPlayerState,
            leftPlayerNotifier: leftPlayerNotifier,
            rightPlayerNotifier: rightPlayerNotifier,
          ),
        ),
        AppWidgetValues.field,
        Expanded(
          child: _StatsComparisonCard(
            left: state.leftSession,
            right: state.rightSession,
          ),
        ),
      ],
    );
  }
}

class _FootbarEmptyState extends StatelessWidget {
  const _FootbarEmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: AppWidgetValues.borderRadiusXl,
          boxShadow: AppWidgetValues.cardShadow,
        ),
        child: Text(
          "K této sezoně neexistují záznamy",
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PlayerSelectCard extends StatelessWidget {
  final PlayerDropdownState leftPlayerState;
  final PlayerDropdownState rightPlayerState;
  final PlayerDropdownNotifier leftPlayerNotifier;
  final PlayerDropdownNotifier rightPlayerNotifier;

  const _PlayerSelectCard({
    required this.leftPlayerState,
    required this.rightPlayerState,
    required this.leftPlayerNotifier,
    required this.rightPlayerNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppWidgetValues.borderRadiusXl,
        boxShadow: AppWidgetValues.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomDropdown(
              hint: "Levý hráč",
              notifier: leftPlayerNotifier,
              state: leftPlayerState,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomDropdown(
              hint: "Pravý hráč",
              notifier: rightPlayerNotifier,
              state: rightPlayerState,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsComparisonCard extends StatelessWidget {
  final FootbarSession? left;
  final FootbarSession? right;

  const _StatsComparisonCard({
    required this.left,
    required this.right,
  });

  String _label(
      FootbarSession? left,
      FootbarSession? right,
      String Function(FootbarSession) getter,
      String fallback,
      ) {
    if (left != null) return getter(left);
    if (right != null) return getter(right);
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _buildTextStatRow(
        label: _label(left, right, (s) => s.positionString(), "Pozice"),
        leftText: left?.positionValueString() ?? "N/A",
        rightText: right?.positionValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.playingTimeString(), "Hrací doba"),
        leftNum: left?.playingTime,
        rightNum: right?.playingTime,
        leftText: left?.playingTimeValueString() ?? "N/A",
        rightText: right?.playingTimeValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.scoreStarsString(), "Footbar hodnocení"),
        leftNum: left?.scoreStars,
        rightNum: right?.scoreStars,
        leftText: left?.scoreStarsValueString() ?? "N/A",
        rightText: right?.scoreStarsValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.distanceString(), "Vzdálenost"),
        leftNum: left?.distance,
        rightNum: right?.distance,
        leftText: left?.distanceValueString() ?? "N/A",
        rightText: right?.distanceValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.passCountString(), "Počet přihrávek"),
        leftNum: left?.passCount,
        rightNum: right?.passCount,
        leftText: left?.passCountValueString() ?? "N/A",
        rightText: right?.passCountValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.shotCountString(), "Počet střel"),
        leftNum: left?.shotCount,
        rightNum: right?.shotCount,
        leftText: left?.shotCountValueString() ?? "N/A",
        rightText: right?.shotCountValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.shotSpeedString(), "Rychlost střely"),
        leftNum: left?.shotSpeed,
        rightNum: right?.shotSpeed,
        leftText: left?.shotSpeedValueString() ?? "N/A",
        rightText: right?.shotSpeedValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.avgShotSpeedString(), "Průměrná rychlost střely"),
        leftNum: left?.avgShotSpeed,
        rightNum: right?.avgShotSpeed,
        leftText: left?.avgShotSpeedValueString() ?? "N/A",
        rightText: right?.avgShotSpeedValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.dribbleCountString(), "Počet driblinků"),
        leftNum: left?.dribbleCount,
        rightNum: right?.dribbleCount,
        leftText: left?.dribbleCountValueString() ?? "N/A",
        rightText: right?.dribbleCountValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.timeWithBallString(), "Čas s míčem"),
        leftNum: left?.timeWithBall,
        rightNum: right?.timeWithBall,
        leftText: left?.timeWithBallValueString() ?? "N/A",
        rightText: right?.timeWithBallValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.activityString(), "Aktivní čas"),
        leftNum: left?.activity,
        rightNum: right?.activity,
        leftText: left?.activityValueString() ?? "N/A",
        rightText: right?.activityValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.timeRunningString(), "Čas v běhu"),
        leftNum: left?.timeRunning,
        rightNum: right?.timeRunning,
        leftText: left?.timeRunningValueString() ?? "N/A",
        rightText: right?.timeRunningValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.runCountString(), "Počet popoběhnutí"),
        leftNum: left?.runCount,
        rightNum: right?.runCount,
        leftText: left?.runCountValueString() ?? "N/A",
        rightText: right?.runCountValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.sprintCountString(), "Počet sprintů"),
        leftNum: left?.sprintCount,
        rightNum: right?.sprintCount,
        leftText: left?.sprintCountValueString() ?? "N/A",
        rightText: right?.sprintCountValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.avgSprintSpeedString(), "Průměrná rychlost sprintu"),
        leftNum: left?.avgSprintSpeed,
        rightNum: right?.avgSprintSpeed,
        leftText: left?.avgSprintSpeedValueString() ?? "N/A",
        rightText: right?.avgSprintSpeedValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.sprintSpeedString(), "Max sprint"),
        leftNum: left?.sprintSpeed,
        rightNum: right?.sprintSpeed,
        leftText: left?.sprintSpeedValueString() ?? "N/A",
        rightText: right?.sprintSpeedValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.hsrPlusString(), "Usprintovaná vzdálenost"),
        leftNum: left?.hsrPlus,
        rightNum: right?.hsrPlus,
        leftText: left?.hsrPlusValueString() ?? "N/A",
        rightText: right?.hsrPlusValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.stopAndGoString(), "Index intenzity"),
        leftNum: left?.stopAndGo,
        rightNum: right?.stopAndGo,
        leftText: left?.stopAndGoValueString() ?? "N/A",
        rightText: right?.stopAndGoValueString() ?? "N/A",
      ),
      _buildNumericStatRow(
        label: _label(left, right, (s) => s.accelerationString(), "Index zrychlení"),
        leftNum: left?.acceleration,
        rightNum: right?.acceleration,
        leftText: left?.accelerationValueString() ?? "N/A",
        rightText: right?.accelerationValueString() ?? "N/A",
      ),
    ];

    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: AppWidgetValues.borderRadiusXl,
          boxShadow: AppWidgetValues.cardShadow,
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: rows.length,
          separatorBuilder: (_, __) => Divider(
            height: 18,
            color: colors.disabled.withAlpha(45),
          ),
          itemBuilder: (_, index) => rows[index],
        ),
      ),
    );
  }

  Widget _buildTextStatRow({
    required String label,
    required String leftText,
    required String rightText,
  }) {
    return _FootbarCompareRow(
      label: label,
      leftText: leftText,
      rightText: rightText,
    );
  }

  Widget _buildNumericStatRow({
    required String label,
    required num? leftNum,
    required num? rightNum,
    required String leftText,
    required String rightText,
  }) {
    var leftBetter = false;
    var rightBetter = false;

    if (leftNum != null && rightNum != null) {
      leftBetter = leftNum > rightNum;
      rightBetter = rightNum > leftNum;
    } else if (leftNum != null) {
      leftBetter = true;
    } else if (rightNum != null) {
      rightBetter = true;
    }

    return _FootbarCompareRow(
      label: label,
      leftText: leftText,
      rightText: rightText,
      leftHighlighted: leftBetter,
      rightHighlighted: rightBetter,
    );
  }
}

class _FootbarCompareRow extends StatelessWidget {
  final String label;
  final String leftText;
  final String rightText;
  final bool leftHighlighted;
  final bool rightHighlighted;

  const _FootbarCompareRow({
    required this.label,
    required this.leftText,
    required this.rightText,
    this.leftHighlighted = false,
    this.rightHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: _CompareValue(
            text: leftText,
            align: TextAlign.right,
            highlighted: leftHighlighted,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 132,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _CompareValue(
            text: rightText,
            align: TextAlign.left,
            highlighted: rightHighlighted,
          ),
        ),
      ],
    );
  }
}

class _CompareValue extends StatelessWidget {
  final String text;
  final TextAlign align;
  final bool highlighted;

  const _CompareValue({
    required this.text,
    required this.align,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      text,
      textAlign: align,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: textTheme.bodyMedium?.copyWith(
        color: highlighted ? colors.accent : colors.textPrimary,
        fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
        height: 1.2,
      ),
    );
  }
}

class PlayerDropdownState implements IDropdownState {
  final FootbarCompareState state;
  final bool isLeft;

  PlayerDropdownState(this.state, {required this.isLeft});

  @override
  DropdownItem? getSelected() =>
      isLeft ? state.leftSelectedPlayer : state.rightSelectedPlayer;

  @override
  AsyncValue<List<DropdownItem>> getDropdownItems() => state.players;
}

class PlayerDropdownNotifier implements IDropdownNotifier {
  final FootbarCompareNotifier notifier;
  final bool isLeft;

  PlayerDropdownNotifier(this.notifier, {required this.isLeft});

  @override
  void selectDropdown(DropdownItem item) {
    final player = item as PlayerApiModel;
    if (isLeft) {
      notifier.setLeftPlayer(player);
    } else {
      notifier.setRightPlayer(player);
    }
  }
}