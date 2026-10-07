import Foundation
import Testing
@testable import smarttrip2_0

struct UserFacingErrorMapperTests {
    @Test func unexpectedSystemErrorUsesSafeFallback() {
        let error = NSError(
            domain: "NSCocoaErrorDomain",
            code: 134110,
            userInfo: [NSLocalizedDescriptionKey: "SQLite store is corrupted"]
        )

        let message = UserFacingErrorMapper.message(
            for: error,
            fallback: "Your trip couldn’t be saved. Try again."
        )

        #expect(message == "Your trip couldn’t be saved. Try again.")
    }

    @Test func domainErrorKeepsSpecificMessageAndRecoveryGuidance() {
        let error = CreateTripError.invalidTravelDates

        #expect(
            UserFacingErrorMapper.message(for: error, fallback: "Your trip couldn’t be saved. Try again.")
                == "The trip cannot end before it starts."
        )
        #expect(
            UserFacingErrorMapper.recoverySuggestion(for: error)
                == "Choose an end date that is the same as or later than the start date."
        )
    }
}
