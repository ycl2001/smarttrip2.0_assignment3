import Foundation

struct CaptureSharedPlaceUseCase {
    private let tripRepository: any TripRepository
    private let savedPlaceRepository: any SavedPlaceRepository

    init(
        tripRepository: any TripRepository,
        savedPlaceRepository: any SavedPlaceRepository
    ) {
        self.tripRepository = tripRepository
        self.savedPlaceRepository = savedPlaceRepository
    }

    func execute(
        tripID: UUID,
        name: String,
        url: URL? = nil,
        notes: String? = nil,
        dateSaved: Date = Date()
    ) throws -> SavedPlace {
        guard try tripRepository.fetchTrip(id: tripID) != nil else {
            throw CaptureSharedPlaceError.tripNotFound
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw CaptureSharedPlaceError.missingPlaceName
        }

        if let url {
            let alreadyExists = try savedPlaceRepository.savedPlaceExists(
                url: url,
                tripID: tripID
            )

            guard !alreadyExists else {
                throw CaptureSharedPlaceError.placeAlreadySaved
            }
        }

        let savedPlace = SavedPlace(
            tripID: tripID,
            name: trimmedName,
            url: url,
            notes: notes,
            status: .idea,
            dateSaved: dateSaved
        )

        try savedPlaceRepository.saveSavedPlace(savedPlace)
        return savedPlace
    }
}
