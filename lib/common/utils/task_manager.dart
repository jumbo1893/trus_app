import 'package:workmanager/workmanager.dart';

class TaskManager {

  static const simpleTaskKey = "simpleTask";
  static const rescheduledTaskKey = "rescheduledTask";
  static const failedTaskKey = "failedTask";
  static const simpleDelayedTask = "simpleDelayedTask";
  static const simplePeriodicTask = "simplePeriodicTask";
  static const simplePeriodic1HourTask = "simplePeriodic1HourTask";

  @pragma(
      'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
  void callbackDispatcher() {
    print("callbackDispatcher");
    Workmanager().executeTask((task, inputData) async {
      print("executeTask");
      print(inputData);
      print(task);
      switch (task) {
        case simpleTaskKey:
          print("$simpleTaskKey was executed. inputData = $inputData");
          print("Bool from prefs:");
          break;
        case rescheduledTaskKey:
          final key = inputData!['key']!;
          print('has been running before, task is successful');
          break;
        case failedTaskKey:
          print('failed task');
          return Future.error('failed');
        case Workmanager.iOSBackgroundTask:
          print("The iOS background fetch was triggered");
          print(
              "You can access other plugins in the background, for example Directory.getTemporaryDirectory():");
          break;
        case simplePeriodicTask:
          print("$simplePeriodicTask was executed");
          break;
        case simpleDelayedTask:
          print("$simpleDelayedTask was executed");
          break;
      }
      return Future.value(true);
    });
  }
}