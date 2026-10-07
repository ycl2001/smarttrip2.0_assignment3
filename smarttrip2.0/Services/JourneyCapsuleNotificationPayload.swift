import Foundation

enum JourneyCapsuleNotificationContract {
    static let categoryIdentifier = "JOURNEY_CAPSULE_REMINDER"
    static let openJourneyCapsuleActionIdentifier = "OPEN_JOURNEY_CAPSULE"
}

struct JourneyCapsuleNotificationPayload: Equatable {
    let tripID: UUID
    let tripName: String
    let destination: String?
    let tripDay: Int?
    let promptText: String

    static let defaultPrompt = "Add a moment to your Journey Capsule while it's still fresh."

    init(
        tripID: UUID,
        tripName: String,
        destination: String? = nil,
        tripDay: Int? = nil,
        promptText: String = Self.defaultPrompt
    ) {
        self.tripID = tripID
        self.tripName = tripName
        self.destination = destination?.trimmedNonEmpty
        self.tripDay = tripDay.flatMap { $0 > 0 ? $0 : nil }
        self.promptText = promptText.trimmedNonEmpty ?? Self.defaultPrompt
    }

    init?(
        userInfo: [AnyHashable: Any]
    ) {
        guard
            let tripIDString = userInfo[Key.tripID] as? String,
            let tripID = UUID(uuidString: tripIDString),
            let tripName = (userInfo[Key.tripName] as? String)?.trimmedNonEmpty
        else {
            return nil
        }

        let destination = (userInfo[Key.destination] as? String)?.trimmedNonEmpty
        let tripDay = Self.tripDayValue(from: userInfo[Key.tripDay])
        let promptText = (userInfo[Key.promptText] as? String)?.trimmedNonEmpty ?? Self.defaultPrompt

        self.init(
            tripID: tripID,
            tripName: tripName,
            destination: destination,
            tripDay: tripDay,
            promptText: promptText
        )
    }

    var userInfo: [String: Any] {
        var userInfo: [String: Any] = [
            Key.tripID: tripID.uuidString,
            Key.tripName: tripName,
            Key.promptText: promptText
        ]

        if let destination {
            userInfo[Key.destination] = destination
        }

        if let tripDay {
            userInfo[Key.tripDay] = tripDay
        }

        return userInfo
    }

    private static func tripDayValue(
        from value: Any?
    ) -> Int? {
        if let day = value as? Int, day > 0 {
            return day
        }

        if let dayNumber = value as? NSNumber {
            let day = dayNumber.intValue
            return day > 0 ? day : nil
        }

        return nil
    }

    private enum Key {
        static let tripID = "tripID"
        static let tripName = "tripName"
        static let destination = "destination"
        static let tripDay = "tripDay"
        static let promptText = "promptText"
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
