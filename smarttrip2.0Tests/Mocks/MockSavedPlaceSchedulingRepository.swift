import Foundation
@testable import smarttrip2_0

final class MockSavedPlaceSchedulingRepository: SavedPlaceSchedulingRepository {
    var errorToThrow: Error?
    var scheduleCallCount = 0
    var capturedSavedPlaceID: UUID?
    var capturedItineraryItem: ItineraryItem?

    func schedule(
        savedPlaceID: UUID,
        itineraryItem: ItineraryItem
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        scheduleCallCount += 1
        capturedSavedPlaceID = savedPlaceID
        capturedItineraryItem = itineraryItem
    }
}
