import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/error.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/auth/controller/auth_controller.dart';
import 'package:trus_app/features/auth/screens/login_screen.dart';
import 'package:trus_app/features/main/main_screen.dart';
import 'package:trus_app/router.dart';
import 'package:trus_app/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trus_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Trusí aplikace",
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: blackColor,
        )
      ),
      onGenerateRoute:  (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider).when(
        data: (user) {
          if (user == null) {
            return const LoginScreen();
          }
          return const MainScreen();
      }, error: (error, trace) {
          return ErrorScreen(error: error.toString(),);
      }, loading: () => const Loader())
    );
  }
}
