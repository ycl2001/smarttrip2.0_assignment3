import Foundation
import Testing
@testable import smarttrip2_0

@MainActor
struct JourneyCapsuleNotificationPayloadTests {
    @Test func completePayloadRoundTripsThroughUserInfo() throws {
        let tripID = try #require(UUID(uuidString: "AB98F0EB-38F5-4F82-8997-B58D87D06F6A"))
        let payload = smarttrip2_0.JourneyCapsuleNotificationPayload(
            tripID: tripID,
            tripName: "Tokyo Trip",
            destination: "Tokyo",
            tripDay: 3,
            promptText: "Capture today's journey."
        )

        let decoded = smarttrip2_0.JourneyCapsuleNotificationPayload(userInfo: payload.userInfo)

        #expect(decoded == payload)
    }

    @Test func payloadOmitsMissingDestinationAndTripDay() throws {
        let tripID = try #require(UUID(uuidString: "75D83F90-7B40-481A-B3F3-86482246E31F"))
        let payload = smarttrip2_0.JourneyCapsuleNotificationPayload(
            tripID: tripID,
            tripName: "Fiji Trip"
        )

        #expect(payload.userInfo["destination"] == nil)
        #expect(payload.userInfo["tripDay"] == nil)

        let decoded = smarttrip2_0.JourneyCapsuleNotificationPayload(userInfo: payload.userInfo)
        #expect(decoded?.destination == nil)
        #expect(decoded?.tripDay == nil)
        #expect(decoded?.promptText == smarttrip2_0.JourneyCapsuleNotificationPayload.defaultPrompt)
    }

    @Test func malformedTripIDIsRejectedSafely() {
        let decoded = smarttrip2_0.JourneyCapsuleNotificationPayload(
            userInfo: [
                "tripID": "not-a-uuid",
                "tripName": "Tokyo Trip",
                "promptText": "Capture today's journey."
            ]
        )

        #expect(decoded == nil)
    }

    @Test func invalidTripDayIsTreatedAsAbsent() throws {
        let tripID = try #require(UUID(uuidString: "9E47F78F-19F5-4C41-A69B-DA173CB5042B"))
        let decoded = smarttrip2_0.JourneyCapsuleNotificationPayload(
            userInfo: [
                "tripID": tripID.uuidString,
                "tripName": "Tokyo Trip",
                "tripDay": 0,
                "promptText": "Capture today's journey."
            ]
        )

        #expect(decoded?.tripDay == nil)
    }

    @Test func missingPromptUsesDefaultPrompt() throws {
        let tripID = try #require(UUID(uuidString: "19A5019D-4A52-4981-B788-5BDEB3DCB85E"))
        let decoded = smarttrip2_0.JourneyCapsuleNotificationPayload(
            userInfo: [
                "tripID": tripID.uuidString,
                "tripName": "Tokyo Trip"
            ]
        )

        #expect(decoded?.promptText == smarttrip2_0.JourneyCapsuleNotificationPayload.defaultPrompt)
    }
}
