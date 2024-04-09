import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/features/steps/controller/step_controller.dart';
import 'package:trus_app/models/api/step/step_api_model.dart';

import '../../../common/widgets/confirmation_dialog.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:permission_handler/permission_handler.dart';


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
  int _stepsNumber = 0;

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pedometer Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Steps Taken',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                _steps,
                style: TextStyle(fontSize: 60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
