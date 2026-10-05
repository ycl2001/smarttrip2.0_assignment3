import Foundation
import Testing
@testable import smarttrip2_0

@MainActor
struct CaptureSharedPlaceUseCaseTests {
    @Test func captureSharedPlaceSavesNewPlaceAsIdea() throws {
        let trip = TestFixtures.trip()
        let tripRepository = MockTripRepository(trips: [trip])
        let savedPlaceRepository = MockSavedPlaceRepository()
        let useCase = CaptureSharedPlaceUseCase(
            tripRepository: tripRepository,
            savedPlaceRepository: savedPlaceRepository
        )
        let url = try #require(URL(string: "https://example.com/teamlab"))

        let place = try useCase.execute(
            tripID: trip.id,
            name: "TeamLab Planets",
            url: url,
            notes: "Book ahead",
            dateSaved: TestDates.december10
        )

        #expect(savedPlaceRepository.saveCallCount == 1)
        #expect(savedPlaceRepository.lastSavedPlace == place)
        #expect(place.tripID == trip.id)
        #expect(place.status == .idea)
        #expect(place.url == url)
    }

    @Test func captureSharedPlaceRejectsDuplicateURLInSameTrip() throws {
        let trip = TestFixtures.trip()
        let url = try #require(URL(string: "https://example.com/teamlab"))
        let existingPlace = TestFixtures.savedPlace(
            tripID: trip.id,
            url: url
        )
        let tripRepository = MockTripRepository(trips: [trip])
        let savedPlaceRepository = MockSavedPlaceRepository(savedPlaces: [existingPlace])
        let useCase = CaptureSharedPlaceUseCase(
            tripRepository: tripRepository,
            savedPlaceRepository: savedPlaceRepository
        )

        #expect(throws: CaptureSharedPlaceError.placeAlreadySaved) {
            try useCase.execute(
                tripID: trip.id,
                name: "TeamLab Again",
                url: url
            )
        }

        #expect(savedPlaceRepository.saveCallCount == 0)
        #expect(savedPlaceRepository.savedPlaces.count == 1)
    }

    @Test func captureSharedPlaceAllowsSameURLInDifferentTrip() throws {
        let tokyoTrip = TestFixtures.trip(name: "Tokyo 2027")
        let japanTrip = TestFixtures.trip(name: "Japan 2028")
        let url = try #require(URL(string: "https://example.com/teamlab"))
        let existingPlace = TestFixtures.savedPlace(
            tripID: japanTrip.id,
            url: url
        )
        let tripRepository = MockTripRepository(trips: [tokyoTrip, japanTrip])
        let savedPlaceRepository = MockSavedPlaceRepository(savedPlaces: [existingPlace])
        let useCase = CaptureSharedPlaceUseCase(
            tripRepository: tripRepository,
            savedPlaceRepository: savedPlaceRepository
        )

        let place = try useCase.execute(
            tripID: tokyoTrip.id,
            name: "TeamLab Planets",
            url: url
        )

        #expect(savedPlaceRepository.saveCallCount == 1)
        #expect(place.tripID == tokyoTrip.id)
        #expect(savedPlaceRepository.savedPlaces.count == 2)
    }

    @Test func captureSharedPlaceRejectsMissingPlaceName() throws {
        let trip = TestFixtures.trip()
        let tripRepository = MockTripRepository(trips: [trip])
        let savedPlaceRepository = MockSavedPlaceRepository()
        let useCase = CaptureSharedPlaceUseCase(
            tripRepository: tripRepository,
            savedPlaceRepository: savedPlaceRepository
        )

        #expect(throws: CaptureSharedPlaceError.missingPlaceName) {
            try useCase.execute(
                tripID: trip.id,
                name: "   "
            )
        }

        #expect(savedPlaceRepository.saveCallCount == 0)
        #expect(savedPlaceRepository.savedPlaces.isEmpty)
    }
}
