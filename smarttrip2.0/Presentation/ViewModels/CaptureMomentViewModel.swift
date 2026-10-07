import CoreLocation
import Foundation
import Observation

@MainActor @Observable
final class CaptureMomentViewModel {
    var locationText = ""
    var caption = ""
    var capturedAt = Date()
    var isSaving = false
    var errorMessage: String?
    var recoverySuggestion: String?
    var locationMessage: String?
    var isUsingCurrentLocation = false

    @ObservationIgnored private let captureJourneyMemoryUseCase: CaptureJourneyMemoryUseCase
    @ObservationIgnored private let placeAutocomplete: any PlaceAutocompleteProviding
    @ObservationIgnored private let currentLocation: any CurrentLocationProviding

    var locationSuggestions: [PlaceSuggestion] {
        Array(placeAutocomplete.suggestions.prefix(3))
    }

    init(
        captureJourneyMemoryUseCase: CaptureJourneyMemoryUseCase,
        placeAutocomplete: any PlaceAutocompleteProviding,
        currentLocation: any CurrentLocationProviding
    ) {
        self.captureJourneyMemoryUseCase = captureJourneyMemoryUseCase
        self.placeAutocomplete = placeAutocomplete
        self.currentLocation = currentLocation
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

    func useCurrentLocation() async {
        guard !isUsingCurrentLocation else {
            return
        }

        isUsingCurrentLocation = true
        locationMessage = nil
        defer { isUsingCurrentLocation = false }

        if currentLocation.authorizationStatus == .notDetermined {
            await currentLocation.requestWhenInUseAuthorization()
        }

        switch currentLocation.authorizationStatus {
        case .denied, .restricted, .notDetermined:
            locationMessage = "Location access is off. You can enter a place manually or enable location in Settings."
            return
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            locationMessage = "We couldn't determine your current location. Try again or enter the place manually."
            return
        }

        do {
            let location = try await currentLocation.currentLocation()
            let place = try await currentLocation.readablePlace(for: location)
            locationText = place
            placeAutocomplete.clearSuggestions()
        } catch {
            locationMessage = "We couldn't determine your current location. Try again or enter the place manually."
        }
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
