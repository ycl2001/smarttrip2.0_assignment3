import Foundation

protocol TravelContentProcessing {
    func process(
        _ input: ActionTravelInput
    ) async throws -> TravelDiscoveryResult
}

struct TravelContentProcessor: TravelContentProcessing {
    private let recommendationProvider: any TravelRecommendationProviding

    init(
        recommendationProvider: any TravelRecommendationProviding
    ) {
        self.recommendationProvider = recommendationProvider
    }

    func process(
        _ input: ActionTravelInput
    ) async throws -> TravelDiscoveryResult {
        let candidateText = candidateText(from: input)

        guard let candidateText else {
            throw TravelContentProcessingError.emptyInput
        }

        let extraction = extractPlaceAndLocation(from: candidateText)
        let summary = makeSummary(
            placeName: extraction.placeName,
            location: extraction.location,
            fallbackText: candidateText,
            sourceURL: input.sourceURL
        )

        let recommendations: [TravelRecommendation]
        do {
            recommendations = try await recommendationProvider.recommendations(
                for: extraction.placeName,
                location: extraction.location
            )
        } catch {
            recommendations = []
        }

        return TravelDiscoveryResult(
            sourceURL: input.sourceURL,
            placeName: extraction.placeName,
            location: extraction.location,
            summary: summary,
            recommendations: recommendations
        )
    }

    private func candidateText(
        from input: ActionTravelInput
    ) -> String? {
        if let sourceTitle = input.sourceTitle?.trimmedNonEmpty {
            return sourceTitle
        }

        if let sharedText = input.sharedText?.trimmedNonEmpty {
            return sharedText
        }

        return input.sourceURL.map(urlDerivedText)
    }

    private func urlDerivedText(
        from url: URL
    ) -> String {
        let host = url.host()?
            .replacingOccurrences(of: "www.", with: "")
            .replacingOccurrences(of: ".", with: " ")
        let path = url.pathComponents
            .filter { $0 != "/" }
            .joined(separator: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")

        return [path, host]
            .compactMap { $0?.trimmedNonEmpty }
            .joined(separator: " ")
    }

    private func extractPlaceAndLocation(
        from text: String
    ) -> (placeName: String?, location: String?) {
        let cleanedText = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let commaParts = cleanedText
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if commaParts.count >= 2 {
            return (
                placeName: commaParts.first,
                location: commaParts.dropFirst().joined(separator: ", ")
            )
        }

        if let location = knownLocation(in: cleanedText) {
            let placeName = cleanedText
                .replacingOccurrences(of: location, with: "", options: [.caseInsensitive])
                .replacingOccurrences(of: " in ", with: " ", options: [.caseInsensitive])
                .replacingOccurrences(of: " near ", with: " ", options: [.caseInsensitive])
                .trimmingCharacters(in: .whitespacesAndNewlines)

            return (
                placeName: normalizedTopic(from: placeName),
                location: location
            )
        }

        return (
            placeName: normalizedTopic(from: cleanedText),
            location: nil
        )
    }

    private func knownLocation(
        in text: String
    ) -> String? {
        let locations = [
            "New Zealand",
            "Queenstown",
            "Matamata",
            "Fiji",
            "Denarau",
            "Mamanuca",
            "Tokyo",
            "Azabudai Hills"
        ]

        return locations.first { location in
            text.range(of: location, options: [.caseInsensitive]) != nil
        }
    }

    private func normalizedTopic(
        from text: String
    ) -> String? {
        let lowered = text.lowercased()

        if lowered.contains("rooftop") && lowered.contains("restaurant") {
            return "Rooftop restaurant"
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        return trimmed
    }

    private func makeSummary(
        placeName: String?,
        location: String?,
        fallbackText: String,
        sourceURL: URL?
    ) -> String {
        if let placeName, let location {
            if placeName.lowercased().contains("restaurant") {
                return "\(placeName) in \(location) suitable for food and trip planning."
            }

            if location.localizedCaseInsensitiveContains("Fiji") {
                return "\(placeName) in \(location) suitable for leisure and island itinerary planning."
            }

            if location.localizedCaseInsensitiveContains("New Zealand") {
                return "\(placeName) in \(location) suitable for nature, sightseeing, or itinerary planning."
            }

            return "\(placeName) in \(location) suitable for travel planning."
        }

        if let placeName {
            return "\(placeName) may be useful for travel planning. Add a location if needed."
        }

        if sourceURL != nil {
            return "Shared travel link saved for review. Add place and location details if needed."
        }

        return String(fallbackText.prefix(140))
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
