import Foundation
import Testing
@testable import smarttrip2_0

@MainActor
struct CaptureMomentViewModelTests {
    @Test func typingLocationProducesSuggestions() {
        let queenstown = PlaceSuggestion(
            title: "Queenstown",
            subtitle: "Otago, New Zealand"
        )
        let autocomplete = MockPlaceAutocompleteService(
            suggestionsByQuery: ["Queenst": [queenstown]]
        )
        let viewModel = makeViewModel(placeAutocomplete: autocomplete)

        viewModel.updateLocationText("Queenst")

        #expect(viewModel.locationText == "Queenst")
        #expect(viewModel.locationSuggestions == [queenstown])
    }

    @Test func selectingSuggestionUpdatesLocationAndClearsSuggestions() {
        let queenstown = PlaceSuggestion(
            title: "Queenstown Gardens",
            subtitle: "Queenstown, New Zealand"
        )
        let autocomplete = MockPlaceAutocompleteService(
            suggestions: [queenstown]
        )
        let viewModel = makeViewModel(placeAutocomplete: autocomplete)

        viewModel.selectLocationSuggestion(queenstown)

        #expect(viewModel.locationText == "Queenstown Gardens, Queenstown, New Zealand")
        #expect(viewModel.locationSuggestions.isEmpty)
    }

    @Test func locationSuggestionsAreLimitedToThree() {
        let suggestions = (1...4).map {
            PlaceSuggestion(title: "Queenstown \($0)")
        }
        let autocomplete = MockPlaceAutocompleteService(suggestions: suggestions)
        let viewModel = makeViewModel(placeAutocomplete: autocomplete)

        #expect(viewModel.locationSuggestions == Array(suggestions.prefix(3)))
    }

    @Test func noResultsDoesNotBlockManualLocationSave() throws {
        let trip = TestFixtures.trip()
        let memoryRepository = MockMemoryRepository()
        let viewModel = makeViewModel(
            trip: trip,
            memoryRepository: memoryRepository,
            placeAutocomplete: MockPlaceAutocompleteService()
        )
        viewModel.updateLocationText("Queenstown")
        viewModel.caption = "A quiet walk beside the lake."

        let memory = try #require(viewModel.save(tripID: trip.id))

        #expect(memory.location == "Queenstown")
        #expect(memoryRepository.memories == [memory])
    }

    @Test func autocompleteFailureDoesNotPreventSavingManualLocation() throws {
        let trip = TestFixtures.trip()
        let memoryRepository = MockMemoryRepository()
        let autocomplete = MockPlaceAutocompleteService()
        autocomplete.markUnavailable()
        let viewModel = makeViewModel(
            trip: trip,
            memoryRepository: memoryRepository,
            placeAutocomplete: autocomplete
        )
        viewModel.updateLocationText("Queenstown")
        viewModel.caption = "Fresh snow on the mountains."

        let memory = try #require(viewModel.save(tripID: trip.id))

        #expect(memory.location == "Queenstown")
        #expect(viewModel.errorMessage == nil)
    }

    private func makeViewModel(
        trip: Trip? = nil,
        memoryRepository: MockMemoryRepository? = nil,
        placeAutocomplete: MockPlaceAutocompleteService
    ) -> CaptureMomentViewModel {
        let trip = trip ?? TestFixtures.trip()
        let memoryRepository = memoryRepository ?? MockMemoryRepository()
        let useCase = CaptureJourneyMemoryUseCase(
            tripRepository: MockTripRepository(trips: [trip]),
            memoryRepository: memoryRepository
        )

        return CaptureMomentViewModel(
            captureJourneyMemoryUseCase: useCase,
            placeAutocomplete: placeAutocomplete
        )
    }
}
