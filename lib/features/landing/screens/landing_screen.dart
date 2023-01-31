import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/custom_button.dart';

class LandingScreen extends StatelessWidget {

  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text(
              "Trusí aplikace",
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600,
            ),
            ),
            SizedBox(height: size.height/9),
            Image.asset('images/logo.jpg'),
            SizedBox(height: size.height/9),
            CustomButton(text: "Přihlaš se", onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
