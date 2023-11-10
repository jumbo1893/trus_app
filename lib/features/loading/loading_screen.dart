import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/custom_text.dart';
import 'package:trus_app/common/widgets/loader.dart';

import '../../common/widgets/custom_button.dart';
import 'kick_and_drink_animation_screen.dart';

class LoadingScreen extends StatelessWidget {
  final Stream<bool> loadingFlag;
  final VoidCallback buttonClicked;
  final String buttonText;
  final String loadingDoneText;
  const LoadingScreen({super.key, required this.loadingFlag, required this.buttonClicked, required this.buttonText, required this.loadingDoneText});
  

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: SizedBox(
                height: 180,
                  width: 180,
                  child: RunAndKickAnimationScreen()),
            ),
          ),
          StreamBuilder<bool>(
            stream: loadingFlag,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || (snapshot.hasData && snapshot.data!)) {
                return Column(
                  children: const [
                    CustomText(text: "Načítám...", fontSize: 25,),
                    Loader(),
                  ],
                );
              }
              return Column(
                children: [
                  CustomText(text: loadingDoneText, fontSize: 25,),
                  CustomButton(
                      text: buttonText,
                      onPressed: () => buttonClicked(),
                      key: const ValueKey('loading_screen_confirm_button')),
                ],
              );
            }
          ),
          const SizedBox(height: 100,)
        ],
      ),
    );
  }
}