import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../common/widgets/loader.dart';

class InfoScreen extends ConsumerStatefulWidget {
  const InfoScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends ConsumerState<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            PackageInfo packageInfo = snapshot.data!;
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Název aplikace: ${packageInfo.appName}"),
                  const SizedBox(height: 15),
                  Text("Verze: ${packageInfo.version}/${packageInfo.buildNumber}"),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
