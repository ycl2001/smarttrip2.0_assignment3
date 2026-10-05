import Foundation

struct PlaceSuggestion: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String

    init(
        id: String? = nil,
        title: String,
        subtitle: String = ""
    ) {
        self.title = title
        self.subtitle = subtitle
        self.id = id ?? [title, subtitle].joined(separator: "|")
    }
}

protocol PlaceAutocompleteProviding: AnyObject {
    var suggestions: [PlaceSuggestion] { get }
    var isUnavailable: Bool { get }

    func updateQuery(_ query: String)
    func clearSuggestions()
}
