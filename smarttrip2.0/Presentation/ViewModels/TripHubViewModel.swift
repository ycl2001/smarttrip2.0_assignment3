import Foundation
import Observation

@Observable
final class TripHubViewModel {
    let tripID: UUID
    var savedPlaceCount = 0
    var itineraryItemCount = 0
    var upcomingItems: [ItineraryItem] = []
    var isLoading = false
    var errorMessage: String?
    var recoverySuggestion: String?

    @ObservationIgnored private let savedPlaceRepository: any SavedPlaceRepository
    @ObservationIgnored private let itineraryRepository: any ItineraryRepository

    init(
        tripID: UUID,
        savedPlaceRepository: any SavedPlaceRepository,
        itineraryRepository: any ItineraryRepository
    ) {
        self.tripID = tripID
        self.savedPlaceRepository = savedPlaceRepository
        self.itineraryRepository = itineraryRepository
    }

    func load() {
        isLoading = true
        defer { isLoading = false }

        do {
            let savedPlaces = try savedPlaceRepository.fetchSavedPlaces(for: tripID)
            let itineraryItems = try itineraryRepository.fetchItineraryItems(for: tripID)
            let upcoming = try itineraryRepository.fetchUpcomingItems(
                for: tripID,
                from: Date()
            )

            savedPlaceCount = savedPlaces.count
            itineraryItemCount = itineraryItems.count
            upcomingItems = Array(upcoming.prefix(3))
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
        let localizedError = error as? any LocalizedError
        errorMessage = localizedError?.errorDescription ?? error.localizedDescription
        recoverySuggestion = localizedError?.recoverySuggestion
    }
}
