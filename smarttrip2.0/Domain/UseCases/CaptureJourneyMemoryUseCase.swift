import Foundation

struct CaptureJourneyMemoryUseCase {
    private let tripRepository: any TripRepository
    private let memoryRepository: any MemoryRepository

    init(
        tripRepository: any TripRepository,
        memoryRepository: any MemoryRepository
    ) {
        self.tripRepository = tripRepository
        self.memoryRepository = memoryRepository
    }

    func execute(
        tripID: UUID,
        itineraryItemID: UUID? = nil,
        location: String? = nil,
        caption: String? = nil,
        photoIdentifier: String? = nil,
        capturedAt: Date = Date()
    ) throws -> TripMemory {
        guard try tripRepository.fetchTrip(id: tripID) != nil else {
            throw CaptureJourneyMemoryError.tripNotFound
        }

        let trimmedLocation = location?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let trimmedCaption = caption?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let trimmedPhotoIdentifier = photoIdentifier?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty

        guard trimmedLocation != nil || trimmedCaption != nil || trimmedPhotoIdentifier != nil else {
            throw CaptureJourneyMemoryError.emptyMemory
        }

        guard capturedAt.timeIntervalSinceReferenceDate.isFinite else {
            throw CaptureJourneyMemoryError.invalidCaptureDate
        }

        let memory = TripMemory(
            tripID: tripID,
            itineraryItemID: itineraryItemID,
            location: trimmedLocation,
            caption: trimmedCaption,
            photoIdentifier: trimmedPhotoIdentifier,
            createdAt: capturedAt
        )

        try memoryRepository.saveMemory(memory)
        return memory
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
