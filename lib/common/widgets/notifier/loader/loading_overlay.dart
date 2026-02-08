import 'package:flutter/material.dart';
import 'package:trus_app/common/utils/utils.dart';

import '../../../../features/general/state/loading_error_state.dart';

@immutable
class LoadingOverlay extends StatelessWidget {
  final LoadingErrorState state;
  final VoidCallback onClearError;
  final VoidCallback? onClearSuccess;
  final Widget child;


  const LoadingOverlay({
    super.key,
    required this.state,
    required this.child,
    required this.onClearError,
    this.onClearSuccess,
  });

  @override
  Widget build(BuildContext context) {
    // ERROR DIALOG
    if (state.loading.errorDialog != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Chyba"),
            content: Text(state.loading.errorDialog!),
            actions: [
              TextButton(
                onPressed: () =>
                    {Navigator.of(context).pop(), onClearError()},
                child: const Text("OK"),
              ),
            ],
          ),
        ).then((_) {
        onClearError();
        });
      });
    }
    // SUCCESS MESSAGE
    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBar(context: context, content: state.successMessage!);
      });
    }
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: state.loading.isLoading,
          child: child,
        ),
        if (state.loading.isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (state.loading.message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.loading.message!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
