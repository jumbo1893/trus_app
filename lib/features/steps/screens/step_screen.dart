import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trus_app/common/utils/utils.dart';

import '../../../common/widgets/confirmation_dialog.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';


class StepScreen extends CustomConsumerStatefulWidget {

  static const String id = "step-screen";
  const StepScreen(
    {
    Key? key,
  }) : super(key: key, title: "Upravit hráče", name: id);

  @override
  ConsumerState<StepScreen> createState() => _StepScreenState();
}

class _StepScreenState extends ConsumerState<StepScreen> {
  String _status = '?', _steps = '?';
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  int steps = 0;
  double exactDistance = 0.0;
  double previousDistance = 0.0;

  @override
  void initState() {
    super.initState();
    grantPermissions();
  }

  Future<void> grantPermissions() async {
    if(Platform.isIOS) {
      PermissionStatus status = await Permission.sensors.status;
      if (!status.isGranted) {
        await Permission.sensors
            .onDeniedCallback(() {
          showSnackBar(context: context,
              content: "Pro počítání kroků musíte dát aplikaci povolení.");
        })
            .onGrantedCallback(() {
          //initPlatformState();
        })
            .onPermanentlyDeniedCallback(() {
          var dialog = ConfirmationDialog(
              "Pro správnou funkci kroků je nutné udělit aplikaci oprávnění pro fyzickou aktivitu", () =>
              openAppSettings());
          showDialog(
              context: context, builder: (BuildContext context) => dialog);
        })
            .onRestrictedCallback(() {
          // Your code
        })
            .onLimitedCallback(() {
          // Your code
        })
            .onProvisionalCallback(() {
          // Your code
        })
            .request();
      }
      else {
        //initPlatformState();
      }
    }
    else if(Platform.isAndroid) {
      PermissionStatus status = await Permission.activityRecognition.status;
      if (!status.isGranted) {
        await Permission.activityRecognition
            .onDeniedCallback(() {
          showSnackBar(context: context,
              content: "Pro počítání kroků musíte dát aplikaci povolení.");
        })
            .onGrantedCallback(() {
          //initPlatformState();
        })
            .onPermanentlyDeniedCallback(() {
          var dialog = ConfirmationDialog(
              "Pro správnou funkci kroků je nutné udělit aplikaci oprávnění pro fyzickou aktivitu", () =>
              openAppSettings());
          showDialog(
              context: context, builder: (BuildContext context) => dialog);
        })
            .onRestrictedCallback(() {
          // Your code
        })
            .onLimitedCallback(() {
          // Your code
        })
            .onProvisionalCallback(() {
          // Your code
        })
            .request();
      }
      else {
        //initPlatformState();
      }
    }
  }



  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  double calculateMagnitude(double x, double y, double z) {
    double distance = sqrt(x * x + y * y + z * z);
    getPreviousValue();
    double mode = distance - previousDistance;
    setPrefData(distance);
    return mode;
  }

  void getPreviousValue() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      previousDistance = pref.getDouble("previousDistance") ?? 0;
    });
  }

  void setPrefData(double predistance) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setDouble("previousDistance", predistance);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pedometer Example'),
        ),
        body: StreamBuilder<int>(
          stream: null,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              x = 1;
              y = 1;
              z = 1;
              print("x$x");
              print("y$y");
              print("z$z");
              exactDistance = calculateMagnitude(x, y, z);
              if (exactDistance > 6) {
                steps++;
                print(steps);
              }
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Steps You Have Hove" + steps.toString(),
                    style: const TextStyle(fontSize: 30),
                  ),
                  Text(
                    _steps,
                    style: const TextStyle(fontSize: 60),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
