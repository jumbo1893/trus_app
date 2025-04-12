import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/general/crud_operations.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';

import '../../../features/general/error/api_executor.dart';
import '../../../features/home/screens/home_screen.dart';
import '../../../features/main/screen_controller.dart';
import '../../utils/utils.dart';
import '../confirmation_dialog.dart';

class ChangeAchievementButton extends ConsumerStatefulWidget {
  final CrudOperations crudOperations;
  final BuildContext context;
  final Function(int) onOperationComplete;
  final PlayerAchievementApiModel playerAchievementApiModel;

  const ChangeAchievementButton({
    Key? key,
    required this.context,
    required this.crudOperations,
    required this.onOperationComplete,
    required this.playerAchievementApiModel,
  }) : super(key: key);

  @override
  ConsumerState<ChangeAchievementButton> createState() => _ChangeAchievementButtonState();
}

class _ChangeAchievementButtonState extends ConsumerState<ChangeAchievementButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (widget.playerAchievementApiModel.achievement.manually) {
      return FloatingActionButton(
        onPressed: _isLoading ? null : onPressed,
        elevation: 4.0,
        child: _isLoading
            ? const Loader() // Loader widget
            : widget.playerAchievementApiModel.isAccomplished ? const Icon(
            Icons.close)
            : const Icon(Icons.check),
      );
    }
    return Container();
  }

  Future<void> onPressed() async {
    setState(() {
      _isLoading = true;
    });
    var dialog = ConfirmationDialog(
      widget.playerAchievementApiModel.toStringForConfirmationDelete(),
          () {
        editAchievement();
      },
    );
    showDialog(
      context: widget.context,
      builder: (BuildContext context) => dialog,
    );
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> editAchievement() async {
    String? response = await executeApi<String?>(() async {
      return await widget.crudOperations.editModel(widget.playerAchievementApiModel.id);
    }, () => ref.read(screenControllerProvider).changeFragment(HomeScreen.id),
        context, false);
    if (response != null) {
      showSnackBar(context: context, content: response);
      widget.onOperationComplete.call(widget.playerAchievementApiModel.player.id!);
    }
  }
}
