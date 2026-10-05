import Foundation
import Testing
import UserNotifications
@testable import smarttrip2_0

struct JourneyCapsuleNotificationSchedulerTests {
    @Test func reminderContentUsesJourneyCapsuleCategory() throws {
        let payload = try Self.makePayload(tripDay: 3)
        let content = JourneyCapsuleNotificationScheduler.makeContent(payload: payload)

        #expect(content.categoryIdentifier == JourneyCapsuleNotificationContract.categoryIdentifier)
    }

    @Test func reminderContentCopiesPayloadUserInfo() throws {
        let payload = try Self.makePayload(tripDay: 3)
        let content = JourneyCapsuleNotificationScheduler.makeContent(payload: payload)
        let decoded = smarttrip2_0.JourneyCapsuleNotificationPayload(userInfo: content.userInfo)

        #expect(decoded == payload)
    }

    @Test func reminderBodyIncludesTripDayWhenAvailable() throws {
        let payload = try Self.makePayload(tripDay: 3)
        let content = JourneyCapsuleNotificationScheduler.makeContent(payload: payload)

        #expect(content.title == "Capture today's journey")
        #expect(content.subtitle == "Tokyo Trip · Day 3")
        #expect(content.body == "You're on Day 3 of your Tokyo Trip. Add a moment to your Journey Capsule while it's still fresh.")
    }

    @Test func reminderBodyOmitsTripDayWhenUnavailable() throws {
        let payload = try Self.makePayload(tripDay: nil)
        let content = JourneyCapsuleNotificationScheduler.makeContent(payload: payload)

        #expect(content.subtitle == "Tokyo Trip · Tokyo")
        #expect(content.body == "Tokyo Trip: Add a moment to your Journey Capsule while it's still fresh.")
    }

    @Test func pastTriggerDateIsRejected() throws {
        let payload = try Self.makePayload(tripDay: 3)
        let now = try #require(Self.now)
        let past = try #require(Self.past)

        #expect(throws: JourneyCapsuleNotificationSchedulingError.invalidTriggerDate) {
            try JourneyCapsuleNotificationScheduler.makeRequest(
                payload: payload,
                at: past,
                now: now,
                calendar: Self.calendar
            )
        }
    }

    @Test func requestIdentifierIncludesTripIDAndTimestamp() throws {
        let payload = try Self.makePayload(tripDay: 3)
        let future = try #require(Self.future)
        let expectedTimestamp = Int(future.timeIntervalSince1970)

        let identifier = JourneyCapsuleNotificationScheduler.requestIdentifier(
            for: payload,
            at: future
        )

        #expect(identifier == "journey-capsule-reminder-\(payload.tripID.uuidString)-\(expectedTimestamp)")
    }

    @Test func requestUsesCalendarTriggerForSuppliedDate() throws {
        let payload = try Self.makePayload(tripDay: 3)
        let now = try #require(Self.now)
        let future = try #require(Self.future)

        let request = try JourneyCapsuleNotificationScheduler.makeRequest(
            payload: payload,
            at: future,
            now: now,
            calendar: Self.calendar
        )

        let trigger = request.trigger as? UNCalendarNotificationTrigger
        #expect(trigger?.repeats == false)
        #expect(trigger?.dateComponents.year == 2026)
        #expect(trigger?.dateComponents.month == 12)
        #expect(trigger?.dateComponents.day == 10)
        #expect(trigger?.dateComponents.hour == 19)
        #expect(trigger?.dateComponents.minute == 30)
    }

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        return calendar
    }()

    private static let now = date(
        year: 2026,
        month: 12,
        day: 10,
        hour: 18,
        minute: 0
    )

    private static let future = date(
        year: 2026,
        month: 12,
        day: 10,
        hour: 19,
        minute: 30
    )

    private static let past = date(
        year: 2026,
        month: 12,
        day: 10,
        hour: 17,
        minute: 30
    )

    private static func makePayload(
        tripDay: Int?
    ) throws -> smarttrip2_0.JourneyCapsuleNotificationPayload {
        smarttrip2_0.JourneyCapsuleNotificationPayload(
            tripID: try #require(UUID(uuidString: "AB98F0EB-38F5-4F82-8997-B58D87D06F6A")),
            tripName: "Tokyo Trip",
            destination: "Tokyo",
            tripDay: tripDay
        )
    }

    private static func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int
    ) -> Date? {
        calendar.date(
            from: DateComponents(
                timeZone: calendar.timeZone,
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute
            )
        )
    }
}
