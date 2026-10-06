import Foundation
import Testing
@testable import smarttrip2_0

@MainActor
struct SavedPlaceViewModelTests {
    @Test func clearPresentationErrorRemovesTransientAddPlaceError() {
        let trip = TestFixtures.trip()
        let viewModel = makeViewModel(trip: trip, savedPlaces: [])

        let captured = viewModel.capturePlace(
            tripID: trip.id,
            name: "   "
        )

        #expect(captured == nil)
        #expect(viewModel.errorMessage == CaptureSharedPlaceError.missingPlaceName.localizedDescription)

        viewModel.clearPresentationError()

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.recoverySuggestion == nil)
    }

    @Test func bulkScheduleSelectedPlacesUsesAtomicRepositoryForEachValidPlace() {
        let trip = TestFixtures.trip()
        let firstPlace = TestFixtures.savedPlace(tripID: trip.id, name: "Tsukiji Market")
        let secondPlace = TestFixtures.savedPlace(tripID: trip.id, name: "Meiji Shrine")
        let schedulingRepository = MockSavedPlaceSchedulingRepository()
        let viewModel = makeViewModel(
            trip: trip,
            savedPlaces: [firstPlace, secondPlace],
            schedulingRepository: schedulingRepository
        )

        viewModel.loadSavedPlaces(for: trip.id)

        let result = viewModel.scheduleSavedPlaces(
            [
                scheduleRequest(for: firstPlace),
                scheduleRequest(for: secondPlace, startTime: TestDates.december12At10)
            ],
            tripID: trip.id
        )

        #expect(result.scheduledCount == 2)
        #expect(result.failures.isEmpty)
        #expect(schedulingRepository.scheduleCallCount == 2)
    }

    @Test func bulkScheduleSelectedPlacesReportsValidationFailureWithoutAtomicSave() {
        let trip = TestFixtures.trip()
        let validPlace = TestFixtures.savedPlace(tripID: trip.id, name: "Tsukiji Market")
        let invalidPlace = TestFixtures.savedPlace(tripID: trip.id, name: "After Trip Cafe")
        let schedulingRepository = MockSavedPlaceSchedulingRepository()
        let viewModel = makeViewModel(
            trip: trip,
            savedPlaces: [validPlace, invalidPlace],
            schedulingRepository: schedulingRepository
        )

        viewModel.loadSavedPlaces(for: trip.id)

        let result = viewModel.scheduleSavedPlaces(
            [
                scheduleRequest(for: validPlace),
                scheduleRequest(
                    for: invalidPlace,
                    scheduledDate: TestDates.december16,
                    startTime: TestDates.december16At10
                )
            ],
            tripID: trip.id
        )

        #expect(result.scheduledCount == 1)
        #expect(result.failures.count == 1)
        #expect(result.failures.first?.savedPlaceID == invalidPlace.id)
        #expect(result.failures.first?.message == ScheduleSavedPlaceError.outsideTripDates.localizedDescription)
        #expect(schedulingRepository.scheduleCallCount == 1)
    }

    private func makeViewModel(
        trip: Trip,
        savedPlaces: [SavedPlace],
        schedulingRepository: MockSavedPlaceSchedulingRepository? = nil
    ) -> SavedPlaceViewModel {
        let tripRepository = MockTripRepository(trips: [trip])
        let savedPlaceRepository = MockSavedPlaceRepository(savedPlaces: savedPlaces)
        let schedulingRepository = schedulingRepository ?? MockSavedPlaceSchedulingRepository()

        return SavedPlaceViewModel(
            captureSharedPlaceUseCase: CaptureSharedPlaceUseCase(
                tripRepository: tripRepository,
                savedPlaceRepository: savedPlaceRepository
            ),
            scheduleSavedPlaceUseCase: ScheduleSavedPlaceUseCase(
                tripRepository: tripRepository,
                savedPlaceRepository: savedPlaceRepository,
                schedulingRepository: schedulingRepository,
                calendar: TestDates.calendar
            ),
            savedPlaceRepository: savedPlaceRepository
        )
    }

    private func scheduleRequest(
        for place: SavedPlace,
        scheduledDate: Date = TestDates.december12,
        startTime: Date = TestDates.december12At10
    ) -> SavedPlaceViewModel.ScheduleRequest {
        SavedPlaceViewModel.ScheduleRequest(
            savedPlaceID: place.id,
            scheduledDate: scheduledDate,
            startTime: startTime,
            endTime: nil,
            notes: place.notes,
            category: .activity
        )
    }
}
