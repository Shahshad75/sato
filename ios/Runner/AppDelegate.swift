import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "imageUploader/sharedImage"
    private var sharedImage: URL?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

        methodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "getSharedImage" {
                if let sharedImage = self?.sharedImage {
                    result(sharedImage.absoluteString)
                } else {
                    result(nil)
                }
            } else if call.method == "readBytes", let args = call.arguments as? String, let url = URL(string: args) {
                do {
                    let data = try Data(contentsOf: url)
                    result(FlutterStandardTypedData(bytes: data))
                } catch {
                    result(FlutterError(code: "UNAVAILABLE", message: "Could not read bytes from URL", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        sharedImage = url
        if let controller = window?.rootViewController as? FlutterViewController {
            let methodChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
            methodChannel.invokeMethod("newIntent", arguments: nil)
        }
        return true
    }
}
