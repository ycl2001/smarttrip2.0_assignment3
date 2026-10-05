import Testing
@testable import smarttrip2_0

@MainActor
struct PlaceAutocompleteServiceTests {
    @Test func shortQueryClearsSuggestions() {
        let service = MockPlaceAutocompleteService(
            suggestions: [
                PlaceSuggestion(title: "Tokyo", subtitle: "Japan")
            ]
        )

        service.updateQuery("T")

        #expect(service.suggestions.isEmpty)
        #expect(service.isUnavailable == false)
    }

    @Test func validQueryReturnsMockedSuggestions() {
        let tokyo = PlaceSuggestion(title: "Tokyo", subtitle: "Japan")
        let station = PlaceSuggestion(title: "Tokyo Station", subtitle: "Chiyoda City")
        let service = MockPlaceAutocompleteService(
            suggestionsByQuery: [
                "Tok": [tokyo, station]
            ]
        )

        service.updateQuery("Tok")

        #expect(service.suggestions == [tokyo, station])
    }

    @Test func clearingSuggestionsResetsUnavailableState() {
        let service = MockPlaceAutocompleteService(
            suggestions: [
                PlaceSuggestion(title: "teamLab Borderless", subtitle: "Azabudai Hills")
            ]
        )

        service.markUnavailable()
        service.clearSuggestions()

        #expect(service.suggestions.isEmpty)
        #expect(service.isUnavailable == false)
    }

    @Test func unavailableAutocompleteDoesNotPreventManualValues() {
        let service = MockPlaceAutocompleteService(isUnavailable: true)
        let manualDestination = "Neighbourhood ramen shop"

        service.updateQuery(manualDestination)

        #expect(service.isUnavailable == true)
        #expect(manualDestination == "Neighbourhood ramen shop")
    }
}
