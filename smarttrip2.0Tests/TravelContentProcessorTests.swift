import Foundation
import Testing
@testable import SmartTripActionExtension

struct TravelContentProcessorTests {
    @Test func newZealandPlaceTextProducesDiscoveryResult() async throws {
        let processor = TravelContentProcessor(
            recommendationProvider: MockRecommendationProvider(
                recommendations: [
                    TravelRecommendation(name: "Fiordland National Park", subtitle: "Southland", category: "Park")
                ]
            )
        )
        let input = ActionTravelInput(sharedText: "Milford Sound, New Zealand")

        let result = try await processor.process(input)

        #expect(result.placeName == "Milford Sound")
        #expect(result.location == "New Zealand")
        #expect(result.summary.isEmpty == false)
        #expect(result.recommendations.count == 1)
    }

    @Test func fijiPlaceTextProducesDiscoveryResult() async throws {
        let processor = TravelContentProcessor(recommendationProvider: MockRecommendationProvider())
        let input = ActionTravelInput(sharedText: "Denarau Island, Fiji")

        let result = try await processor.process(input)

        #expect(result.placeName == "Denarau Island")
        #expect(result.location == "Fiji")
        #expect(result.summary.localizedCaseInsensitiveContains("Fiji"))
    }

    @Test func recommendationFailureStillReturnsDiscoveryResult() async throws {
        let processor = TravelContentProcessor(
            recommendationProvider: MockRecommendationProvider(shouldThrow: true)
        )
        let input = ActionTravelInput(sharedText: "Hobbiton Movie Set, Matamata, New Zealand")

        let result = try await processor.process(input)

        #expect(result.placeName == "Hobbiton Movie Set")
        #expect(result.location == "Matamata, New Zealand")
        #expect(result.recommendations.isEmpty)
    }

    @Test func urlOnlyInputPreservesSourceURLAndProducesSummary() async throws {
        let processor = TravelContentProcessor(recommendationProvider: MockRecommendationProvider())
        let url = try #require(URL(string: "https://www.newzealand.com/us/milford-sound/"))
        let input = ActionTravelInput(sourceURL: url)

        let result = try await processor.process(input)

        #expect(result.sourceURL == url)
        #expect(result.summary.isEmpty == false)
    }

    @Test func emptyInputThrowsEmptyInputError() async {
        let processor = TravelContentProcessor(recommendationProvider: MockRecommendationProvider())
        let input = ActionTravelInput()

        await #expect(throws: TravelContentProcessingError.emptyInput) {
            try await processor.process(input)
        }
    }
}

private struct MockRecommendationProvider: TravelRecommendationProviding {
    var recommendations: [TravelRecommendation] = []
    var shouldThrow = false

    func recommendations(
        for placeName: String?,
        location: String?
    ) async throws -> [TravelRecommendation] {
        if shouldThrow {
            throw TravelContentProcessingError.unsupportedContent
        }

        return recommendations
    }
}
