import Foundation
import Observation

@Observable
final class CaptureMomentViewModel {
    var locationText = ""
    var caption = ""
    var capturedAt = Date()
    var isSaving = false
    var errorMessage: String?
    var recoverySuggestion: String?

    @ObservationIgnored private let captureJourneyMemoryUseCase: CaptureJourneyMemoryUseCase
    @ObservationIgnored private let placeAutocomplete: any PlaceAutocompleteProviding

    var locationSuggestions: [PlaceSuggestion] {
        Array(placeAutocomplete.suggestions.prefix(3))
    }

    init(
        captureJourneyMemoryUseCase: CaptureJourneyMemoryUseCase,
        placeAutocomplete: any PlaceAutocompleteProviding
    ) {
        self.captureJourneyMemoryUseCase = captureJourneyMemoryUseCase
        self.placeAutocomplete = placeAutocomplete
    }

    func updateLocationText(
        _ locationText: String
    ) {
        self.locationText = locationText
        placeAutocomplete.updateQuery(locationText)
    }

    func selectLocationSuggestion(
        _ suggestion: PlaceSuggestion
    ) {
        locationText = displayValue(for: suggestion)
        placeAutocomplete.clearSuggestions()
    }

    func clearLocationSuggestions() {
        placeAutocomplete.clearSuggestions()
    }

    @discardableResult
    func save(
        tripID: UUID
    ) -> TripMemory? {
        guard !isSaving else {
            return nil
        }

        isSaving = true
        defer {
            isSaving = false
        }

        do {
            let memory = try captureJourneyMemoryUseCase.execute(
                tripID: tripID,
                location: locationText,
                caption: caption,
                capturedAt: capturedAt
            )
            clearPresentationError()
            return memory
        } catch {
            present(error)
            return nil
        }
    }

    func clearPresentationError() {
        errorMessage = nil
        recoverySuggestion = nil
    }

    private func displayValue(
        for suggestion: PlaceSuggestion
    ) -> String {
        guard !suggestion.subtitle.isEmpty else {
            return suggestion.title
        }

        return "\(suggestion.title), \(suggestion.subtitle)"
    }

    private func present(
        _ error: Error
    ) {
        let localizedError = error as? any LocalizedError
        errorMessage = localizedError?.errorDescription ?? error.localizedDescription
        recoverySuggestion = localizedError?.recoverySuggestion
    }
}
