import Foundation
import Testing
@testable import smarttrip2_0

@MainActor
struct CaptureJourneyMemoryUseCaseTests {
    @Test func captureJourneyMemorySavesValidMemory() throws {
        let trip = TestFixtures.trip()
        let tripRepository = MockTripRepository(trips: [trip])
        let memoryRepository = MockMemoryRepository()
        let useCase = CaptureJourneyMemoryUseCase(
            tripRepository: tripRepository,
            memoryRepository: memoryRepository
        )

        let memory = try useCase.execute(
            tripID: trip.id,
            location: "Shibuya Crossing",
            caption: "  Neon lights after dinner.  ",
            capturedAt: TestDates.december12At10
        )

        #expect(memoryRepository.saveCallCount == 1)
        #expect(memoryRepository.lastSavedMemory == memory)
        #expect(memory.tripID == trip.id)
        #expect(memory.location == "Shibuya Crossing")
        #expect(memory.caption == "Neon lights after dinner.")
        #expect(memory.createdAt == TestDates.december12At10)
    }

    @Test func captureJourneyMemoryRejectsMissingTrip() {
        let tripRepository = MockTripRepository()
        let memoryRepository = MockMemoryRepository()
        let useCase = CaptureJourneyMemoryUseCase(
            tripRepository: tripRepository,
            memoryRepository: memoryRepository
        )

        #expect(throws: CaptureJourneyMemoryError.tripNotFound) {
            try useCase.execute(
                tripID: UUID(),
                caption: "A quiet morning."
            )
        }

        #expect(memoryRepository.saveCallCount == 0)
    }

    @Test func captureJourneyMemoryRejectsCompletelyEmptyMemory() throws {
        let trip = TestFixtures.trip()
        let tripRepository = MockTripRepository(trips: [trip])
        let memoryRepository = MockMemoryRepository()
        let useCase = CaptureJourneyMemoryUseCase(
            tripRepository: tripRepository,
            memoryRepository: memoryRepository
        )

        #expect(throws: CaptureJourneyMemoryError.emptyMemory) {
            try useCase.execute(
                tripID: trip.id,
                location: " ",
                caption: "   ",
                photoIdentifier: nil
            )
        }

        #expect(memoryRepository.saveCallCount == 0)
    }

    @Test func captureJourneyMemoryPreservesTripRelationshipAndPhotoReference() throws {
        let trip = TestFixtures.trip()
        let tripRepository = MockTripRepository(trips: [trip])
        let memoryRepository = MockMemoryRepository()
        let useCase = CaptureJourneyMemoryUseCase(
            tripRepository: tripRepository,
            memoryRepository: memoryRepository
        )

        let memory = try useCase.execute(
            tripID: trip.id,
            photoIdentifier: "local-photo-001",
            capturedAt: TestDates.december12At10
        )

        #expect(memory.tripID == trip.id)
        #expect(memory.photoIdentifier == "local-photo-001")
        #expect(memoryRepository.memories.map(\.id) == [memory.id])
    }
}
