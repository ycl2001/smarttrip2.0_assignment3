import Foundation
import Testing
@testable import smarttrip2_0

@MainActor
struct ScheduleSavedPlaceUseCaseTests {
    @Test func scheduleSavedPlaceCreatesItineraryItemAndMarksPlaceScheduled() throws {
        let trip = TestFixtures.trip()
        let savedPlace = TestFixtures.savedPlace(tripID: trip.id)
        let tripRepository = MockTripRepository(trips: [trip])
        let savedPlaceRepository = MockSavedPlaceRepository(savedPlaces: [savedPlace])
        let itineraryRepository = MockItineraryRepository()
        let useCase = ScheduleSavedPlaceUseCase(
            tripRepository: tripRepository,
            savedPlaceRepository: savedPlaceRepository,
            itineraryRepository: itineraryRepository,
            calendar: TestDates.calendar
        )

        let item = try useCase.execute(
            savedPlaceID: savedPlace.id,
            tripID: trip.id,
            scheduledDate: TestDates.december12,
            startTime: TestDates.december12At10,
            category: .activity
        )

        #expect(itineraryRepository.saveCallCount == 1)
        #expect(savedPlaceRepository.updateCallCount == 1)
        #expect(item.sourceSavedPlaceID == savedPlace.id)
        #expect(item.title == savedPlace.name)
        #expect(savedPlaceRepository.lastUpdatedSavedPlace?.status == .scheduled)
    }

    @Test func scheduleSavedPlaceRejectsDateOutsideTrip() throws {
        let trip = TestFixtures.trip()
        let savedPlace = TestFixtures.savedPlace(tripID: trip.id)
        let tripRepository = MockTripRepository(trips: [trip])
        let savedPlaceRepository = MockSavedPlaceRepository(savedPlaces: [savedPlace])
        let itineraryRepository = MockItineraryRepository()
        let useCase = ScheduleSavedPlaceUseCase(
            tripRepository: tripRepository,
            savedPlaceRepository: savedPlaceRepository,
            itineraryRepository: itineraryRepository,
            calendar: TestDates.calendar
        )

        #expect(throws: ScheduleSavedPlaceError.outsideTripDates) {
            try useCase.execute(
                savedPlaceID: savedPlace.id,
                tripID: trip.id,
                scheduledDate: TestDates.december16,
                startTime: TestDates.december16At10
            )
        }

        #expect(itineraryRepository.saveCallCount == 0)
        #expect(savedPlaceRepository.updateCallCount == 0)
        #expect(savedPlaceRepository.savedPlaces.first?.status == .idea)
    }

    @Test func scheduleSavedPlaceRejectsAlreadyScheduledPlace() throws {
        let trip = TestFixtures.trip()
        let savedPlace = TestFixtures.savedPlace(
            tripID: trip.id,
            status: .scheduled
        )
        let tripRepository = MockTripRepository(trips: [trip])
        let savedPlaceRepository = MockSavedPlaceRepository(savedPlaces: [savedPlace])
        let itineraryRepository = MockItineraryRepository()
        let useCase = ScheduleSavedPlaceUseCase(
            tripRepository: tripRepository,
            savedPlaceRepository: savedPlaceRepository,
            itineraryRepository: itineraryRepository,
            calendar: TestDates.calendar
        )

        #expect(throws: ScheduleSavedPlaceError.alreadyScheduled) {
            try useCase.execute(
                savedPlaceID: savedPlace.id,
                tripID: trip.id,
                scheduledDate: TestDates.december12,
                startTime: TestDates.december12At10
            )
        }

        #expect(itineraryRepository.saveCallCount == 0)
        #expect(savedPlaceRepository.updateCallCount == 0)
    }
}
