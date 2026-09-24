import Foundation
import Testing
@testable import smarttrip2_0

struct CreateTripUseCaseTests {
    @Test func createTripSavesValidTrip() throws {
        let tripRepository = MockTripRepository()
        let useCase = CreateTripUseCase(tripRepository: tripRepository)

        let trip = try useCase.execute(
            name: "Tokyo Graduation Trip",
            destination: "Tokyo",
            startDate: TestDates.december10,
            endDate: TestDates.december15
        )

        #expect(tripRepository.saveCallCount == 1)
        #expect(tripRepository.trips.count == 1)
        #expect(tripRepository.lastSavedTrip == trip)
        #expect(trip.name == "Tokyo Graduation Trip")
        #expect(trip.destination == "Tokyo")
    }

    @Test func createTripRejectsEndDateBeforeStartDate() {
        let tripRepository = MockTripRepository()
        let useCase = CreateTripUseCase(tripRepository: tripRepository)

        #expect(throws: CreateTripError.invalidTravelDates) {
            try useCase.execute(
                name: "Tokyo Graduation Trip",
                destination: "Tokyo",
                startDate: TestDates.december15,
                endDate: TestDates.december10
            )
        }

        #expect(tripRepository.saveCallCount == 0)
        #expect(tripRepository.trips.isEmpty)
    }
}
