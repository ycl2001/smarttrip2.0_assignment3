import Foundation
import Observation

@Observable
final class SavedPlacesOverviewViewModel {
    struct TripSavedPlaces: Identifiable {
        let trip: Trip
        let places: [SavedPlace]

        var id: UUID {
            trip.id
        }
    }

    var groups: [TripSavedPlaces] = []
    var isLoading = false
    var errorMessage: String?
    var recoverySuggestion: String?

    @ObservationIgnored private let tripRepository: any TripRepository
    @ObservationIgnored private let savedPlaceRepository: any SavedPlaceRepository

    init(
        tripRepository: any TripRepository,
        savedPlaceRepository: any SavedPlaceRepository
    ) {
        self.tripRepository = tripRepository
        self.savedPlaceRepository = savedPlaceRepository
    }

    func load() {
        isLoading = true
        defer { isLoading = false }

        do {
            let trips = try tripRepository.fetchTrips()
            groups = try trips.compactMap { trip in
                let places = try savedPlaceRepository.fetchSavedPlaces(for: trip.id)

                guard !places.isEmpty else {
                    return nil
                }

                return TripSavedPlaces(
                    trip: trip,
                    places: places
                )
            }
            .sorted { $0.trip.startDate > $1.trip.startDate }
            clearError()
        } catch {
            present(error)
        }
    }

    private func clearError() {
        errorMessage = nil
        recoverySuggestion = nil
    }

    private func present(
        _ error: Error
    ) {
        errorMessage = UserFacingErrorMapper.message(for: error, fallback: "We couldn’t load your saved places. Try again.")
        recoverySuggestion = UserFacingErrorMapper.recoverySuggestion(for: error)
    }
}
