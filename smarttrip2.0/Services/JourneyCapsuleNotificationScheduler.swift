import Foundation
import UserNotifications

protocol JourneyCapsuleNotificationScheduling {
    @discardableResult
    func scheduleReminder(
        payload: JourneyCapsuleNotificationPayload,
        at date: Date
    ) async throws -> String
}

protocol JourneyCapsuleNotificationAuthorizing {
    func requestAuthorization() async throws -> Bool
}

struct JourneyCapsuleNotificationAuthorizer: JourneyCapsuleNotificationAuthorizing {
    private let notificationCenter: UNUserNotificationCenter

    init(
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.notificationCenter = notificationCenter
    }

    func requestAuthorization() async throws -> Bool {
        let settings = await notificationCenter.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return try await notificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
        @unknown default:
            return false
        }
    }
}

enum JourneyCapsuleNotificationSchedulingError: LocalizedError, Equatable {
    case invalidTriggerDate

    var errorDescription: String? {
        switch self {
        case .invalidTriggerDate:
            "Journey Capsule reminders must be scheduled for a future time."
        }
    }
}

protocol JourneyCapsuleNotificationCenterAdding {
    func add(
        _ request: UNNotificationRequest
    ) async throws
}

extension UNUserNotificationCenter: JourneyCapsuleNotificationCenterAdding {}

struct JourneyCapsuleNotificationScheduler: JourneyCapsuleNotificationScheduling {
    private let notificationCenter: any JourneyCapsuleNotificationCenterAdding
    private let calendar: Calendar
    private let now: () -> Date

    init(
        notificationCenter: any JourneyCapsuleNotificationCenterAdding = UNUserNotificationCenter.current(),
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.notificationCenter = notificationCenter
        self.calendar = calendar
        self.now = now
    }

    @discardableResult
    func scheduleReminder(
        payload: JourneyCapsuleNotificationPayload,
        at date: Date
    ) async throws -> String {
        let request = try Self.makeRequest(
            payload: payload,
            at: date,
            now: now(),
            calendar: calendar
        )

        try await notificationCenter.add(request)
        return request.identifier
    }

    static func makeRequest(
        payload: JourneyCapsuleNotificationPayload,
        at date: Date,
        now: Date = Date(),
        calendar: Calendar = .current
    ) throws -> UNNotificationRequest {
        guard date > now else {
            throw JourneyCapsuleNotificationSchedulingError.invalidTriggerDate
        }

        let content = makeContent(payload: payload)
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        return UNNotificationRequest(
            identifier: requestIdentifier(for: payload, at: date),
            content: content,
            trigger: trigger
        )
    }

    static func makeContent(
        payload: JourneyCapsuleNotificationPayload
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Capture a moment"
        content.subtitle = subtitle(for: payload)
        content.body = body(for: payload)
        content.categoryIdentifier = JourneyCapsuleNotificationContract.categoryIdentifier
        content.userInfo = payload.userInfo
        content.sound = .default
        return content
    }

    static func requestIdentifier(
        for payload: JourneyCapsuleNotificationPayload,
        at date: Date
    ) -> String {
        let timestamp = Int(date.timeIntervalSince1970)
        return "journey-capsule-reminder-\(payload.tripID.uuidString)-\(timestamp)"
    }

    private static func subtitle(
        for payload: JourneyCapsuleNotificationPayload
    ) -> String {
        let tripName = payload.tripName.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayTripName = tripName.isEmpty ? "Your Trip" : tripName

        if let destination = payload.destination {
            return "\(displayTripName) · \(destination)"
        }

        return displayTripName
    }

    private static func body(
        for payload: JourneyCapsuleNotificationPayload
    ) -> String {
        "Add something from today to your Journey Capsule."
    }
}
