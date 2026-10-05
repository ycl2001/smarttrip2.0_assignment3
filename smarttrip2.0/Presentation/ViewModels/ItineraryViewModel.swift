import Foundation
import Observation

@Observable
final class ItineraryViewModel {
    let tripID: UUID
    var items: [ItineraryItem] = []
    var isLoading = false
    var errorMessage: String?
    var recoverySuggestion: String?

    @ObservationIgnored private let itineraryRepository: any ItineraryRepository

    init(
        tripID: UUID,
        itineraryRepository: any ItineraryRepository
    ) {
        self.tripID = tripID
        self.itineraryRepository = itineraryRepository
    }

    func load() {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try itineraryRepository.fetchItineraryItems(for: tripID)
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
