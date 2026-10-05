import Foundation
import Testing
import UserNotifications
@testable import smarttrip2_0

struct JourneyCapsuleNotificationResponseHandlerTests {
    @Test func journeyCapsuleReminderExtractsTripID() throws {
        let tripID = try #require(UUID(uuidString: "8D6DF476-6D8E-462B-A16E-751099593D3A"))
        let payload = smarttrip2_0.JourneyCapsuleNotificationPayload(
            tripID: tripID,
            tripName: "Tokyo Trip",
            destination: "Tokyo",
            tripDay: 3
        )
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = JourneyCapsuleNotificationContract.categoryIdentifier
        content.userInfo = payload.userInfo

        let routedTripID = JourneyCapsuleNotificationResponseHandler()
            .journeyCapsuleTripID(from: content)

        #expect(routedTripID == tripID)
    }

    @Test func unrelatedNotificationCategoryIsIgnored() throws {
        let tripID = try #require(UUID(uuidString: "B3BC43D9-6E51-455F-A031-6F373171E77F"))
        let payload = smarttrip2_0.JourneyCapsuleNotificationPayload(
            tripID: tripID,
            tripName: "Fiji Trip"
        )
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "OTHER_CATEGORY"
        content.userInfo = payload.userInfo

        let routedTripID = JourneyCapsuleNotificationResponseHandler()
            .journeyCapsuleTripID(from: content)

        #expect(routedTripID == nil)
    }

    @Test func malformedJourneyCapsulePayloadIsIgnoredSafely() {
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = JourneyCapsuleNotificationContract.categoryIdentifier
        content.userInfo = [
            "tripID": "not-a-uuid",
            "tripName": "Tokyo Trip"
        ]

        let routedTripID = JourneyCapsuleNotificationResponseHandler()
            .journeyCapsuleTripID(from: content)

        #expect(routedTripID == nil)
    }
}
