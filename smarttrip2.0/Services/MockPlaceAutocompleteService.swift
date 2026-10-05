import Foundation
import Observation

@Observable
final class MockPlaceAutocompleteService: PlaceAutocompleteProviding {
    private let suggestionsByQuery: [String: [PlaceSuggestion]]

    private(set) var suggestions: [PlaceSuggestion]
    private(set) var isUnavailable: Bool

    init(
        suggestions: [PlaceSuggestion] = [],
        suggestionsByQuery: [String: [PlaceSuggestion]] = [:],
        isUnavailable: Bool = false
    ) {
        self.suggestions = suggestions
        self.suggestionsByQuery = suggestionsByQuery
        self.isUnavailable = isUnavailable
    }

    func updateQuery(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedQuery.count >= 2 else {
            clearSuggestions()
            return
        }

        suggestions = suggestionsByQuery[trimmedQuery] ?? suggestions
    }

    func clearSuggestions() {
        suggestions = []
        isUnavailable = false
    }

    func markUnavailable() {
        suggestions = []
        isUnavailable = true
    }
}
