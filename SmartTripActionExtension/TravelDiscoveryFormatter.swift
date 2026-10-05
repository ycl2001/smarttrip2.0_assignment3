import Foundation

struct TravelDiscoveryFormatter {
    func format(
        _ result: TravelDiscoveryResult
    ) -> String {
        var sections: [String] = []

        if let placeName = result.placeName?.trimmedNonEmpty {
            sections.append("Place: \(placeName)")
        }

        if let location = result.location?.trimmedNonEmpty {
            sections.append("Location: \(location)")
        }

        if let summary = result.summary.trimmedNonEmpty {
            sections.append(
                """
                Summary:
                \(summary)
                """
            )
        }

        let recommendationLines = result.recommendations
            .compactMap { recommendation -> String? in
                guard let name = recommendation.name.trimmedNonEmpty else {
                    return nil
                }

                return "• \(name)"
            }

        if !recommendationLines.isEmpty {
            sections.append(
                """
                Related places:
                \(recommendationLines.joined(separator: "\n"))
                """
            )
        }

        if let source = result.sourceURL?.absoluteString.trimmedNonEmpty {
            sections.append(
                """
                Source:
                \(source)
                """
            )
        }

        return sections.joined(separator: "\n\n")
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
