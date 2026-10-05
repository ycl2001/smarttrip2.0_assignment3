import Foundation
import Testing

struct TravelContentProcessorTests {
    @Test func milfordSoundContentProducesNewZealandTravelDiscovery() async throws {
        let processor = TravelContentProcessor(
            recommendationProvider: MockTravelRecommendationProvider()
        )
        let input = ActionTravelInput(sharedText: "Milford Sound, New Zealand")

        let result = try await processor.process(input)

        #expect(result.placeName == "Milford Sound")
        #expect(result.location?.contains("New Zealand") == true)
        #expect(result.summary.isEmpty == false)
    }

    @Test func denarauIslandContentProducesFijiTravelDiscovery() async throws {
        let processor = TravelContentProcessor(
            recommendationProvider: MockTravelRecommendationProvider()
        )
        let input = ActionTravelInput(sharedText: "Denarau Island, Fiji")

        let result = try await processor.process(input)

        #expect(result.placeName == "Denarau Island")
        #expect(result.location?.contains("Fiji") == true)
        #expect(result.summary.isEmpty == false)
    }

    @Test func mamanucaIslandsContentProducesUsableFijiTravelDiscovery() async throws {
        let processor = TravelContentProcessor(
            recommendationProvider: MockTravelRecommendationProvider()
        )
        let input = ActionTravelInput(sharedText: "Mamanuca Islands, Fiji")

        let result = try await processor.process(input)

        #expect(result.placeName == "Mamanuca Islands")
        #expect(result.location?.contains("Fiji") == true)
        #expect(result.summary.isEmpty == false)
    }

    @Test func urlOnlySharedContentProducesEditableTravelDiscovery() async throws {
        let processor = TravelContentProcessor(
            recommendationProvider: MockTravelRecommendationProvider()
        )
        let url = try #require(URL(string: "https://www.newzealand.com/us/milford-sound/"))
        let input = ActionTravelInput(sourceURL: url)

        let result = try await processor.process(input)

        #expect(result.sourceURL == url)
        #expect(result.placeName?.isEmpty == false)
        #expect(result.summary.isEmpty == false)
    }

    @Test func urlAndTextSharedContentPrefersUsefulText() async throws {
        let processor = TravelContentProcessor(
            recommendationProvider: MockTravelRecommendationProvider()
        )
        let url = try #require(URL(string: "https://example.com/travel"))
        let input = ActionTravelInput(
            sourceURL: url,
            sharedText: "Hobbiton Movie Set, Matamata, New Zealand"
        )

        let result = try await processor.process(input)

        #expect(result.sourceURL == url)
        #expect(result.placeName == "Hobbiton Movie Set")
        #expect(result.location == "Matamata, New Zealand")
    }

    @Test func sourceTitleTakesPriorityOverSharedText() async throws {
        let processor = TravelContentProcessor(
            recommendationProvider: MockTravelRecommendationProvider()
        )
        let input = ActionTravelInput(
            sharedText: "Fallback travel text",
            sourceTitle: "Queenstown, New Zealand"
        )

        let result = try await processor.process(input)

        #expect(result.placeName == "Queenstown")
        #expect(result.location == "New Zealand")
    }

    @Test func placeWithoutLocationStillProducesEditableSummary() async throws {
        let processor = TravelContentProcessor(
            recommendationProvider: MockTravelRecommendationProvider()
        )
        let input = ActionTravelInput(sharedText: "Rooftop restaurant with mountain views")

        let result = try await processor.process(input)

        #expect(result.placeName == "Rooftop restaurant")
        #expect(result.location == nil)
        #expect(result.summary.isEmpty == false)
    }

    @Test func travelDiscoveryRejectsEmptySharedContent() async {
        let processor = TravelContentProcessor(
            recommendationProvider: MockTravelRecommendationProvider()
        )
        let input = ActionTravelInput()

        await #expect(throws: TravelContentProcessingError.emptyInput) {
            try await processor.process(input)
        }
    }

    @Test func travelDiscoveryIncludesMockedRecommendations() async throws {
        let recommendations = [
            TravelRecommendation(name: "Fiordland National Park"),
            TravelRecommendation(name: "Te Anau")
        ]
        let processor = TravelContentProcessor(
            recommendationProvider: MockTravelRecommendationProvider(
                recommendationsToReturn: recommendations
            )
        )
        let input = ActionTravelInput(sharedText: "Milford Sound, New Zealand")

        let result = try await processor.process(input)

        #expect(result.recommendations == recommendations)
    }

    @Test func travelDiscoveryStillSucceedsWhenRecommendationsAreUnavailable() async throws {
        let processor = TravelContentProcessor(
            recommendationProvider: MockTravelRecommendationProvider(
                errorToThrow: TravelContentProcessingError.unsupportedContent
            )
        )
        let input = ActionTravelInput(sharedText: "Milford Sound, New Zealand")

        let result = try await processor.process(input)

        #expect(result.placeName == "Milford Sound")
        #expect(result.location == "New Zealand")
        #expect(result.summary.isEmpty == false)
        #expect(result.recommendations.isEmpty)
    }
}
