import Foundation
import Testing
@testable import smarttrip2_0

struct SavedPlaceViewModelTests {
    @Test func clearPresentationErrorRemovesTransientAddPlaceError() {
        let trip = TestFixtures.trip()
        let viewModel = makeViewModel(
            trip: trip,
            savedPlaces: []
        )

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

    @Test func bulkScheduleSelectedPlacesSchedulesEachValidPlace() {
        let trip = TestFixtures.trip()
        let firstPlace = TestFixtures.savedPlace(tripID: trip.id, name: "Tsukiji Market")
        let secondPlace = TestFixtures.savedPlace(tripID: trip.id, name: "Meiji Shrine")
        let itineraryRepository = MockItineraryRepository()
        let savedPlaceRepository = MockSavedPlaceRepository(savedPlaces: [firstPlace, secondPlace])
        let viewModel = makeViewModel(
            trip: trip,
            savedPlaceRepository: savedPlaceRepository,
            itineraryRepository: itineraryRepository
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
        #expect(itineraryRepository.saveCallCount == 2)
        #expect(savedPlaceRepository.updateCallCount == 2)
        #expect(savedPlaceRepository.savedPlaces.allSatisfy { $0.status == .scheduled })
    }

    @Test func bulkScheduleSelectedPlacesReportsPartialFailure() {
        let trip = TestFixtures.trip()
        let validPlace = TestFixtures.savedPlace(tripID: trip.id, name: "Tsukiji Market")
        let invalidPlace = TestFixtures.savedPlace(tripID: trip.id, name: "After Trip Cafe")
        let itineraryRepository = MockItineraryRepository()
        let savedPlaceRepository = MockSavedPlaceRepository(savedPlaces: [validPlace, invalidPlace])
        let viewModel = makeViewModel(
            trip: trip,
            savedPlaceRepository: savedPlaceRepository,
            itineraryRepository: itineraryRepository
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
        #expect(itineraryRepository.saveCallCount == 1)
        #expect(savedPlaceRepository.savedPlaces.first { $0.id == validPlace.id }?.status == .scheduled)
        #expect(savedPlaceRepository.savedPlaces.first { $0.id == invalidPlace.id }?.status == .idea)
    }

    private func makeViewModel(
        trip: Trip,
        savedPlaces: [SavedPlace]
    ) -> SavedPlaceViewModel {
        makeViewModel(
            trip: trip,
            savedPlaceRepository: MockSavedPlaceRepository(savedPlaces: savedPlaces),
            itineraryRepository: MockItineraryRepository()
        )
    }

    private func makeViewModel(
        trip: Trip,
        savedPlaceRepository: MockSavedPlaceRepository,
        itineraryRepository: MockItineraryRepository
    ) -> SavedPlaceViewModel {
        let tripRepository = MockTripRepository(trips: [trip])

        return SavedPlaceViewModel(
            captureSharedPlaceUseCase: CaptureSharedPlaceUseCase(
                tripRepository: tripRepository,
                savedPlaceRepository: savedPlaceRepository
            ),
            scheduleSavedPlaceUseCase: ScheduleSavedPlaceUseCase(
                tripRepository: tripRepository,
                savedPlaceRepository: savedPlaceRepository,
                itineraryRepository: itineraryRepository,
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
