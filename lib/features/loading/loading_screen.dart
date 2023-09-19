import 'package:flutter/material.dart';

import 'kick_and_drink_animation_screen.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      body: RunAndKickAnimationScreen(),
    );
  }
}