import UIKit
import Flutter
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
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
}