import Foundation
import Testing
@testable import smarttrip2_0

@MainActor
struct ScheduleSavedPlaceUseCaseTests {
    @Test func scheduleSavedPlaceUsesAtomicRepositoryAndPreservesSourceID() throws {
        let trip = TestFixtures.trip()
        let savedPlace = TestFixtures.savedPlace(tripID: trip.id)
        let schedulingRepository = MockSavedPlaceSchedulingRepository()
        let useCase = makeUseCase(
            trip: trip,
            savedPlace: savedPlace,
            schedulingRepository: schedulingRepository
        )

        let item = try useCase.execute(
            savedPlaceID: savedPlace.id,
            tripID: trip.id,
            scheduledDate: TestDates.december12,
            startTime: TestDates.december12At10,
            category: .activity
        )

        #expect(schedulingRepository.scheduleCallCount == 1)
        #expect(schedulingRepository.capturedSavedPlaceID == savedPlace.id)
        #expect(schedulingRepository.capturedItineraryItem == item)
        #expect(item.sourceSavedPlaceID == savedPlace.id)
        #expect(item.title == savedPlace.name)
    }

    @Test func scheduleSavedPlaceReportsTypedErrorWhenAtomicPersistenceFails() {
        let trip = TestFixtures.trip()
        let savedPlace = TestFixtures.savedPlace(tripID: trip.id)
        let schedulingRepository = MockSavedPlaceSchedulingRepository()
        schedulingRepository.errorToThrow = CocoaError(.fileWriteUnknown)
        let useCase = makeUseCase(
            trip: trip,
            savedPlace: savedPlace,
            schedulingRepository: schedulingRepository
        )

        #expect(throws: ScheduleSavedPlaceError.persistenceFailed) {
            try useCase.execute(
                savedPlaceID: savedPlace.id,
                tripID: trip.id,
                scheduledDate: TestDates.december12,
                startTime: TestDates.december12At10
            )
        }

        #expect(schedulingRepository.scheduleCallCount == 0)
        #expect(schedulingRepository.capturedItineraryItem == nil)
    }

    @Test func scheduleSavedPlaceRejectsDateOutsideTrip() {
        let trip = TestFixtures.trip()
        let savedPlace = TestFixtures.savedPlace(tripID: trip.id)
        let schedulingRepository = MockSavedPlaceSchedulingRepository()
        let useCase = makeUseCase(
            trip: trip,
            savedPlace: savedPlace,
            schedulingRepository: schedulingRepository
        )

        #expect(throws: ScheduleSavedPlaceError.outsideTripDates) {
            try useCase.execute(
                savedPlaceID: savedPlace.id,
                tripID: trip.id,
                scheduledDate: TestDates.december16,
                startTime: TestDates.december16At10
            )
        }

        #expect(schedulingRepository.scheduleCallCount == 0)
    }

    @Test func scheduleSavedPlaceAllowsTripStartDate() throws {
        let trip = TestFixtures.trip()
        let savedPlace = TestFixtures.savedPlace(tripID: trip.id)
        let schedulingRepository = MockSavedPlaceSchedulingRepository()
        let useCase = makeUseCase(trip: trip, savedPlace: savedPlace, schedulingRepository: schedulingRepository)

        let item = try useCase.execute(
            savedPlaceID: savedPlace.id,
            tripID: trip.id,
            scheduledDate: TestDates.december10,
            startTime: TestDates.december10At10
        )

        #expect(schedulingRepository.scheduleCallCount == 1)
        #expect(item.tripID == trip.id)
        #expect(TestDates.calendar.isDate(item.date, inSameDayAs: trip.startDate))
    }

    @Test func scheduleSavedPlaceAllowsTripEndDate() throws {
        let trip = TestFixtures.trip()
        let savedPlace = TestFixtures.savedPlace(tripID: trip.id)
        let schedulingRepository = MockSavedPlaceSchedulingRepository()
        let useCase = makeUseCase(trip: trip, savedPlace: savedPlace, schedulingRepository: schedulingRepository)

        let item = try useCase.execute(
            savedPlaceID: savedPlace.id,
            tripID: trip.id,
            scheduledDate: TestDates.december15,
            startTime: TestDates.december15At10
        )

        #expect(schedulingRepository.scheduleCallCount == 1)
        #expect(item.tripID == trip.id)
        #expect(TestDates.calendar.isDate(item.date, inSameDayAs: trip.endDate))
    }

    @Test func scheduleSavedPlaceRejectsAlreadyScheduledPlace() {
        let trip = TestFixtures.trip()
        let savedPlace = TestFixtures.savedPlace(
            tripID: trip.id,
            status: .scheduled
        )
        let schedulingRepository = MockSavedPlaceSchedulingRepository()
        let useCase = makeUseCase(
            trip: trip,
            savedPlace: savedPlace,
            schedulingRepository: schedulingRepository
        )

        #expect(throws: ScheduleSavedPlaceError.alreadyScheduled) {
            try useCase.execute(
                savedPlaceID: savedPlace.id,
                tripID: trip.id,
                scheduledDate: TestDates.december12,
                startTime: TestDates.december12At10
            )
        }

        #expect(schedulingRepository.scheduleCallCount == 0)
    }

    private func makeUseCase(
        trip: Trip,
        savedPlace: SavedPlace,
        schedulingRepository: MockSavedPlaceSchedulingRepository
    ) -> ScheduleSavedPlaceUseCase {
        ScheduleSavedPlaceUseCase(
            tripRepository: MockTripRepository(trips: [trip]),
            savedPlaceRepository: MockSavedPlaceRepository(savedPlaces: [savedPlace]),
            schedulingRepository: schedulingRepository,
            calendar: TestDates.calendar
        )
    }
}
