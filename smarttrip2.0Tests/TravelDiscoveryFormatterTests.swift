import Foundation
import Testing

struct TravelDiscoveryFormatterTests {
    private let formatter = TravelDiscoveryFormatter()

    @Test func formattedTravelBriefIncludesEveryAvailableSection() throws {
        let sourceURL = try #require(URL(string: "https://example.com/milford-sound"))
        let result = TravelDiscoveryResult(
            sourceURL: sourceURL,
            placeName: "Milford Sound",
            location: "New Zealand",
            summary: "Scenic destination suitable for sightseeing.",
            recommendations: [
                TravelRecommendation(name: "Fiordland National Park"),
                TravelRecommendation(name: "Te Anau")
            ]
        )

        let output = formatter.format(result)

        #expect(output.contains("Place: Milford Sound"))
        #expect(output.contains("Location: New Zealand"))
        #expect(output.contains("Summary:"))
        #expect(output.contains("Scenic destination suitable for sightseeing."))
        #expect(output.contains("Related places:"))
        #expect(output.contains("• Fiordland National Park"))
        #expect(output.contains("• Te Anau"))
        #expect(output.contains("Source:"))
        #expect(output.contains("https://example.com/milford-sound"))
    }

    @Test func formattedTravelBriefOmitsMissingLocation() {
        let result = TravelDiscoveryResult(
            sourceURL: nil,
            placeName: "Rooftop restaurant",
            location: nil,
            summary: "Useful for food planning.",
            recommendations: []
        )

        let output = formatter.format(result)

        #expect(output.contains("Place: Rooftop restaurant"))
        #expect(output.contains("Location:") == false)
    }

    @Test func formattedTravelBriefOmitsEmptyRecommendations() {
        let result = TravelDiscoveryResult(
            sourceURL: nil,
            placeName: "Denarau Island",
            location: "Fiji",
            summary: "Island resort area suitable for leisure planning.",
            recommendations: []
        )

        let output = formatter.format(result)

        #expect(output.contains("Related places:") == false)
    }

    @Test func formattedTravelBriefOmitsMissingSourceURL() {
        let result = TravelDiscoveryResult(
            sourceURL: nil,
            placeName: "Mamanuca Islands",
            location: "Fiji",
            summary: "Useful for island itinerary planning."
        )

        let output = formatter.format(result)

        #expect(output.contains("Source:") == false)
    }

    @Test func formattedTravelBriefUsesEditedValues() {
        let result = TravelDiscoveryResult(
            sourceURL: nil,
            placeName: "Milford Sound",
            location: "South Island, New Zealand",
            summary: "Edited summary for the final shared brief.",
            recommendations: [
                TravelRecommendation(name: "Milford Track")
            ]
        )

        let output = formatter.format(result)

        #expect(output.contains("Place: Milford Sound"))
        #expect(output.contains("Location: South Island, New Zealand"))
        #expect(output.contains("Edited summary for the final shared brief."))
        #expect(output.contains("• Milford Track"))
    }
}
