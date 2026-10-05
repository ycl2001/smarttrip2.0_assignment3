import Foundation
import MapKit

struct MapKitTravelRecommendationService: TravelRecommendationProviding {
    private let maximumRecommendationCount = 3

    func recommendations(
        for placeName: String?,
        location: String?
    ) async throws -> [TravelRecommendation] {
        let query = [placeName, location]
            .compactMap { $0?.trimmedNonEmpty }
            .joined(separator: " ")

        guard !query.isEmpty else {
            return []
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.pointOfInterest]

        let response = try await MKLocalSearch(request: request).start()
        let primaryName = placeName?.lowercased()

        return response.mapItems
            .compactMap { item -> TravelRecommendation? in
                guard let name = item.name?.trimmedNonEmpty else {
                    return nil
                }

                if let primaryName, name.lowercased() == primaryName {
                    return nil
                }

                return TravelRecommendation(
                    name: name,
                    subtitle: item.displaySubtitle,
                    category: item.pointOfInterestCategory?.displayTitle
                )
            }
            .uniquedByName()
            .prefix(maximumRecommendationCount)
            .map { $0 }
    }
}

private extension Array where Element == TravelRecommendation {
    func uniquedByName() -> [TravelRecommendation] {
        var seenNames = Set<String>()

        return filter { recommendation in
            seenNames.insert(recommendation.name.lowercased()).inserted
        }
    }
}

private extension MKMapItem {
    var displaySubtitle: String? {
        if #available(iOS 26.0, *) {
            return addressRepresentations?
                .fullAddress(includingRegion: true, singleLine: true)?
                .trimmedNonEmpty
        } else {
            return placemark.title?.trimmedNonEmpty
        }
    }
}

private extension MKPointOfInterestCategory {
    var displayTitle: String {
        rawValue
            .replacingOccurrences(of: "MKPOICategory", with: "")
            .replacingOccurrences(of: "_", with: " ")
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
