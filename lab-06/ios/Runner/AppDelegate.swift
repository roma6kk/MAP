import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let messenger = engineBridge.pluginRegistry.registrar(forPlugin: "Lab06Channels")?.messenger() else {
      return
    }

    FlutterMethodChannel(name: "lab06/sensors", binaryMessenger: messenger).setMethodCallHandler { call, result in
      guard call.method == "getLightLevel" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(FlutterError(
        code: "UNSUPPORTED",
        message: "iOS не предоставляет публичного API для датчика освещённости",
        details: nil
      ))
    }

    FlutterMethodChannel(name: "lab06/battery", binaryMessenger: messenger).setMethodCallHandler { call, result in
      guard call.method == "getBatteryLevel" else {
        result(FlutterMethodNotImplemented)
        return
      }
      UIDevice.current.isBatteryMonitoringEnabled = true
      let level = UIDevice.current.batteryLevel
      guard level >= 0 else {
        result(FlutterError(code: "UNAVAILABLE", message: "Заряд батареи недоступен (симулятор)", details: nil))
        return
      }
      result([
        "level": Int(level * 100),
        "platform": "iOS",
        "api": "UIDevice.current.batteryLevel"
      ])
    }

    FlutterMethodChannel(name: "lab06/apps", binaryMessenger: messenger).setMethodCallHandler { call, result in
      guard call.method == "openMail" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let arguments = call.arguments as? [String: Any]
      let subject = (arguments?["subject"] as? String) ?? ""
      let encoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
      guard let url = URL(string: "mailto:?subject=\(encoded)") else {
        result(FlutterError(code: "BAD_URL", message: "Некорректная тема письма", details: nil))
        return
      }
      UIApplication.shared.open(url, options: [:]) { success in
        result(success)
      }
    }
  }
}
