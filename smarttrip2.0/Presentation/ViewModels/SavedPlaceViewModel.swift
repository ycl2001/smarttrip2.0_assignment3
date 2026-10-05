import Foundation
import Observation

@Observable
final class SavedPlaceViewModel {
    struct ScheduleRequest {
        let savedPlaceID: UUID
        let scheduledDate: Date
        let startTime: Date
        let endTime: Date?
        let notes: String?
        let category: ItineraryCategory
    }

    struct ScheduleFailure: Identifiable, Equatable {
        let id = UUID()
        let savedPlaceID: UUID
        let placeName: String
        let message: String
        let recoverySuggestion: String?
    }

    struct BulkScheduleResult {
        let scheduledItems: [ItineraryItem]
        let failures: [ScheduleFailure]

        var scheduledCount: Int {
            scheduledItems.count
        }

        var hasFailures: Bool {
            !failures.isEmpty
        }

        var isCompleteSuccess: Bool {
            !scheduledItems.isEmpty && failures.isEmpty
        }
    }

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

    @discardableResult
    func scheduleSavedPlaces(
        _ requests: [ScheduleRequest],
        tripID: UUID
    ) -> BulkScheduleResult {
        clearPresentationError()

        var scheduledItems: [ItineraryItem] = []
        var failures: [ScheduleFailure] = []

        for request in requests {
            do {
                let item = try scheduleSavedPlaceUseCase.execute(
                    savedPlaceID: request.savedPlaceID,
                    tripID: tripID,
                    scheduledDate: request.scheduledDate,
                    startTime: request.startTime,
                    endTime: request.endTime,
                    notes: request.notes,
                    category: request.category
                )
                scheduledItems.append(item)
            } catch {
                failures.append(
                    ScheduleFailure(
                        savedPlaceID: request.savedPlaceID,
                        placeName: placeName(for: request.savedPlaceID),
                        message: presentationMessage(for: error),
                        recoverySuggestion: presentationRecoverySuggestion(for: error)
                    )
                )
            }
        }

        loadSavedPlaces(for: tripID)

        return BulkScheduleResult(
            scheduledItems: scheduledItems,
            failures: failures
        )
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

    func clearPresentationError() {
        clearError()
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

    private func presentationMessage(
        for error: Error
    ) -> String {
        let localizedError = error as? any LocalizedError
        return localizedError?.errorDescription ?? error.localizedDescription
    }

    private func presentationRecoverySuggestion(
        for error: Error
    ) -> String? {
        let localizedError = error as? any LocalizedError
        return localizedError?.recoverySuggestion
    }

    private func placeName(
        for id: UUID
    ) -> String {
        savedPlaces.first { $0.id == id }?.name ?? "Saved Place"
    }
}
