import UIKit
import Flutter
import flutter_local_notifications // <-- FIX: This import resolves the build error.

@main // This is the modern replacement for @UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // This is required by flutter_local_notifications to make communication
    // available in the background isolate where notifications are handled.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    // This is required to handle notifications when the app is in the foreground on iOS 10+.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    // This registers all of your app's plugins.
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
