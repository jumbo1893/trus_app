import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/appearance/controller/appearance_notifier.dart';
import 'package:trus_app/firebase_options.dart';
import 'package:trus_app/router.dart';
import 'package:trus_app/services/notification_init_provider.dart';
import 'package:trus_app/theme/app_theme.dart';

import 'config.dart';
import 'features/auth/login/controller/auth_login_controller.dart';
import 'features/auth/login/screens/login_screen.dart';
import 'features/general/repository/queue/lifecycle_event_handler.dart';
import 'my_http_overrides.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  if (automation) {
    enableFlutterDriverExtension();
  }
  if (runningUrl != prodUrl) {
    HttpOverrides.global = MyHttpOverrides();
  }

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final container = ProviderContainer();

  WidgetsBinding.instance.addObserver(
    LifecycleEventHandler(container: container),
  );

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationsInitProvider);
    final themeMode = ref.watch(appearanceNotifierProvider);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: "Trusí aplikace",
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        onGenerateRoute: (settings) => generateRoute(settings),
        home: ref.watch(userDataAuthProvider).when(
            data: (redirect) {
              return ref.read(authLoginControllerProvider).chooseScreenByLoginRedirect(redirect);
            }, error: (error, trace) {
          //showSnackBar(context: context, content: error.toString());
          return const LoginScreen();
        }, loading: () => const Loader())
    );
  }
}
