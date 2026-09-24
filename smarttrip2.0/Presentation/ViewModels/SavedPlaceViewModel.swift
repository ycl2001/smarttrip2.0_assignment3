import Foundation
import Observation

@Observable
final class SavedPlaceViewModel {
    var savedPlaces: [SavedPlace] = []
    var isLoading = false
    var errorMessage: String?
    var recoverySuggestion: String?

    @ObservationIgnored private let captureSharedPlaceUseCase: CaptureSharedPlaceUseCase
    @ObservationIgnored private let scheduleSavedPlaceUseCase: ScheduleSavedPlaceUseCase
    @ObservationIgnored private let savedPlaceRepository: any SavedPlaceRepository

    init(
        captureSharedPlaceUseCase: CaptureSharedPlaceUseCase,
        scheduleSavedPlaceUseCase: ScheduleSavedPlaceUseCase,
        savedPlaceRepository: any SavedPlaceRepository
    ) {
        self.captureSharedPlaceUseCase = captureSharedPlaceUseCase
        self.scheduleSavedPlaceUseCase = scheduleSavedPlaceUseCase
        self.savedPlaceRepository = savedPlaceRepository
    }

    func loadSavedPlaces(
        for tripID: UUID
    ) {
        isLoading = true
        defer { isLoading = false }

        do {
            savedPlaces = try savedPlaceRepository.fetchSavedPlaces(for: tripID)
            clearError()
        } catch {
            present(error)
        }
    }

    @discardableResult
    func capturePlace(
        tripID: UUID,
        name: String,
        url: URL? = nil,
        notes: String? = nil,
        dateSaved: Date = Date()
    ) -> SavedPlace? {
        do {
            let place = try captureSharedPlaceUseCase.execute(
                tripID: tripID,
                name: name,
                url: url,
                notes: notes,
                dateSaved: dateSaved
            )
            loadSavedPlaces(for: tripID)
            return place
        } catch {
            present(error)
            return nil
        }
    }

    @discardableResult
    func scheduleSavedPlace(
        savedPlaceID: UUID,
        tripID: UUID,
        scheduledDate: Date,
        startTime: Date?,
        endTime: Date? = nil,
        notes: String? = nil,
        category: ItineraryCategory = .other
    ) -> ItineraryItem? {
        do {
            let item = try scheduleSavedPlaceUseCase.execute(
                savedPlaceID: savedPlaceID,
                tripID: tripID,
                scheduledDate: scheduledDate,
                startTime: startTime,
                endTime: endTime,
                notes: notes,
                category: category
            )
            loadSavedPlaces(for: tripID)
            return item
        } catch {
            present(error)
            return nil
        }
    }

    func deleteSavedPlace(
        id: UUID,
        tripID: UUID
    ) {
        do {
            try savedPlaceRepository.deleteSavedPlace(id: id)
            loadSavedPlaces(for: tripID)
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
