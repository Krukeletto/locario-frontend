import Flutter
import EventKit
import UIKit
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let calendarStore = EKEventStore()
  private let channelName = "locario/device_calendar"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.alert, .badge, .sound])
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "createEvent" else {
        result(FlutterMethodNotImplemented)
        return
      }

      self?.handleCreateEvent(call: call, result: result)
    }
  }

  private func handleCreateEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let title = arguments["title"] as? String,
      let startMillis = Self.millisecondsValue(arguments["startMillis"]),
      let endMillis = Self.millisecondsValue(arguments["endMillis"])
    else {
      result(
        FlutterError(
          code: "invalid_args",
          message: "Missing calendar event data",
          details: nil
        )
      )
      return
    }

    let createEvent = { [weak self] in
      guard let self else {
        result(
          FlutterError(
            code: "calendar_unavailable",
            message: "Calendar store unavailable",
            details: nil
          )
        )
        return
      }

      guard let calendar = self.calendarStore.defaultCalendarForNewEvents
        ?? self.calendarStore.calendars(for: .event).first(where: { $0.allowsContentModifications })
      else {
        result(
          FlutterError(
            code: "calendar_missing",
            message: "No writable calendar available",
            details: nil
          )
        )
        return
      }

      let event = EKEvent(eventStore: self.calendarStore)
      event.title = title
      event.notes = arguments["description"] as? String
      event.location = arguments["location"] as? String
      event.startDate = Date(timeIntervalSince1970: TimeInterval(startMillis) / 1000.0)
      event.endDate = Date(timeIntervalSince1970: TimeInterval(endMillis) / 1000.0)
      event.calendar = calendar

      do {
        try self.calendarStore.save(event, span: .thisEvent, commit: true)
        result(true)
      } catch {
        result(
          FlutterError(
            code: "calendar_save_failed",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    }

    if Self.canAccessEvents() {
      createEvent()
      return
    }

    calendarStore.requestAccess(to: .event) { granted, error in
      DispatchQueue.main.async {
        if let error {
          result(
            FlutterError(
              code: "calendar_permission_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
          return
        }

        guard granted else {
          result(
            FlutterError(
              code: "calendar_permission_denied",
              message: "Calendar access denied",
              details: nil
            )
          )
          return
        }

        createEvent()
      }
    }
  }

  private static func millisecondsValue(_ value: Any?) -> Int64? {
    if let number = value as? NSNumber {
      return number.int64Value
    }

    if let value = value as? Int64 {
      return value
    }

    if let value = value as? Int {
      return Int64(value)
    }

    return nil
  }

  private static func canAccessEvents() -> Bool {
    if #available(iOS 17.0, *) {
      switch EKEventStore.authorizationStatus(for: .event) {
      case .authorized, .fullAccess, .writeOnly:
        return true
      default:
        return false
      }
    }

    return EKEventStore.authorizationStatus(for: .event) == .authorized
  }
}
