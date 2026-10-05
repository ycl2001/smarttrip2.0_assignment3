import Foundation
import Testing
@testable import smarttrip2_0

@MainActor
struct JourneyCapsuleViewModelTests {
    @Test func journeyCapsuleLoadsMemoriesForSelectedTripOnly() throws {
        let trip = TestFixtures.trip()
        let otherTrip = TestFixtures.trip(name: "Kyoto Trip", destination: "Kyoto")
        let selectedMemory = TestFixtures.memory(tripID: trip.id)
        let otherMemory = TestFixtures.memory(tripID: otherTrip.id)
        let viewModel = makeViewModel(
            trip: trip,
            memories: [selectedMemory, otherMemory]
        )

        viewModel.loadMemories()

        #expect(viewModel.memories.map(\.id) == [selectedMemory.id])
        #expect(viewModel.errorMessage == nil)
    }

    @Test func savingMomentRefreshesDisplayedMemories() throws {
        let trip = TestFixtures.trip()
        let viewModel = makeViewModel(trip: trip)

        let memory = viewModel.captureMoment(
            location: "Shibuya Crossing",
            caption: "A bright walk after dinner.",
            capturedAt: TestDates.december12At18
        )

        let savedMemory = try #require(memory)
        #expect(viewModel.memories.map(\.id) == [savedMemory.id])
        #expect(viewModel.memories.first?.location == "Shibuya Crossing")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func missingLocationIsAllowedWhenCaptionIsPresent() throws {
        let trip = TestFixtures.trip()
        let viewModel = makeViewModel(trip: trip)

        let memory = viewModel.captureMoment(
            location: " ",
            caption: "Quiet train ride back to the hotel.",
            capturedAt: TestDates.december12At18
        )

        let savedMemory = try #require(memory)
        #expect(savedMemory.location == nil)
        #expect(savedMemory.caption == "Quiet train ride back to the hotel.")
    }

    @Test func emptyMemoryShowsDomainErrorAndDoesNotSave() {
        let trip = TestFixtures.trip()
        let viewModel = makeViewModel(trip: trip)

        let memory = viewModel.captureMoment(
            location: " ",
            caption: "   ",
            capturedAt: TestDates.december12At18
        )

        #expect(memory == nil)
        #expect(viewModel.memories.isEmpty)
        #expect(viewModel.errorMessage == CaptureJourneyMemoryError.emptyMemory.errorDescription)
    }

    @Test func failedMemoryFetchShowsHumanReadableError() {
        let trip = TestFixtures.trip()
        let memoryRepository = MockMemoryRepository()
        memoryRepository.errorToThrow = CaptureJourneyMemoryError.tripNotFound
        let viewModel = makeViewModel(
            trip: trip,
            memoryRepository: memoryRepository
        )

        viewModel.loadMemories()

        #expect(viewModel.errorMessage == CaptureJourneyMemoryError.tripNotFound.errorDescription)
        #expect(viewModel.memories.isEmpty)
    }

    @Test func failedSaveKeepsSheetStateAvailableForCorrection() {
        let trip = TestFixtures.trip()
        let memoryRepository = MockMemoryRepository()
        memoryRepository.errorToThrow = CaptureJourneyMemoryError.emptyMemory
        let viewModel = makeViewModel(
            trip: trip,
            memoryRepository: memoryRepository
        )

        let memory = viewModel.captureMoment(
            location: "Tokyo Tower",
            caption: "Evening view.",
            capturedAt: TestDates.december12At18
        )

        #expect(memory == nil)
        #expect(viewModel.isSaving == false)
        #expect(viewModel.errorMessage == CaptureJourneyMemoryError.emptyMemory.errorDescription)
    }

    private func makeViewModel(
        trip: Trip,
        memories: [TripMemory] = [],
        memoryRepository: MockMemoryRepository? = nil
    ) -> JourneyCapsuleViewModel {
        let tripRepository = MockTripRepository(trips: [trip])
        let memoryRepository = memoryRepository ?? MockMemoryRepository(memories: memories)
        let useCase = CaptureJourneyMemoryUseCase(
            tripRepository: tripRepository,
            memoryRepository: memoryRepository
        )

        return JourneyCapsuleViewModel(
            tripID: trip.id,
            memoryRepository: memoryRepository,
            captureJourneyMemoryUseCase: useCase
        )
    }
}
