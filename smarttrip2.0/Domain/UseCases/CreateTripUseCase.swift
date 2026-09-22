import Foundation

struct CreateTripUseCase {
    private let tripRepository: any TripRepository

    init(tripRepository: any TripRepository) {
        self.tripRepository = tripRepository
    }

    func execute(
        name: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        coverImageName: String? = nil
    ) throws -> Trip {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDestination = destination.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw CreateTripError.missingTripName
        }

        guard !trimmedDestination.isEmpty else {
            throw CreateTripError.missingDestination
        }

        guard endDate >= startDate else {
            throw CreateTripError.invalidTravelDates
        }

        let trip = Trip(
            name: trimmedName,
            destination: trimmedDestination,
            startDate: startDate,
            endDate: endDate,
            coverImageName: coverImageName
        )

        try tripRepository.saveTrip(trip)
        return trip
    }
}
