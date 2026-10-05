import Foundation
import MapKit
import Observation

@Observable
final class MapKitPlaceAutocompleteService: NSObject, PlaceAutocompleteProviding {
    private let minimumQueryLength = 2
    private nonisolated static let maximumSuggestionCount = 5
    private let completer: MKLocalSearchCompleter

    private(set) var suggestions: [PlaceSuggestion] = []
    private(set) var isUnavailable = false

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest, .query]
    }

    func updateQuery(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedQuery.count >= minimumQueryLength else {
            clearSuggestions()
            completer.queryFragment = ""
            return
        }

        isUnavailable = false
        suggestions = []
        completer.queryFragment = trimmedQuery
    }

    func clearSuggestions() {
        suggestions = []
        isUnavailable = false
    }
}

extension MapKitPlaceAutocompleteService: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let suggestions = completer.results.prefix(Self.maximumSuggestionCount).map { result in
            PlaceSuggestion(
                title: result.title,
                subtitle: result.subtitle
            )
        }

        Task { @MainActor [weak self] in
            self?.suggestions = suggestions
            self?.isUnavailable = false
        }
    }

    nonisolated func completer(
        _ completer: MKLocalSearchCompleter,
        didFailWithError error: any Error
    ) {
        Task { @MainActor [weak self] in
            self?.suggestions = []
            self?.isUnavailable = true
        }
    }
}
