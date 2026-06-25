import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var backgroundDownloader: BackgroundDownloader?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Use a slight delay or wait for the engine to be fully attached
        // to avoid race conditions with the rootViewController
        DispatchQueue.main.async {
            if let controller = self.window?.rootViewController as? FlutterViewController {
                self.backgroundDownloader = BackgroundDownloader(messenger: controller.binaryMessenger)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        super.application(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
}
