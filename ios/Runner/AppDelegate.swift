import UIKit
import Flutter
import UserNotifications
import FirebaseMessaging
import workmanager_apple

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    WorkmanagerPlugin.registerLaunchHandlers()
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "com.jumbo.trus_app.steps.sync"
    )

    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken

    let tokenParts = deviceToken.map { data in
      String(format: "%02.2hhx", data)
    }
    let token = tokenParts.joined()

    print("[push-diagnostics-native] didRegisterForRemoteNotificationsWithDeviceToken apnsToken=\(token)")

    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("[push-diagnostics-native] didFailToRegisterForRemoteNotificationsWithError error=\(error.localizedDescription)")

    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    print("[push-diagnostics-native] willPresent foreground notification userInfo=\(userInfo)")

    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print("[push-diagnostics-native] didReceive notification response userInfo=\(userInfo)")

    super.userNotificationCenter(
      center,
      didReceive: response,
      withCompletionHandler: completionHandler
    )
  }
}
