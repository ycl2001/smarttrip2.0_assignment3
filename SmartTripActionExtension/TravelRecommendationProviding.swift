import Foundation

protocol TravelRecommendationProviding {
    func recommendations(
        for placeName: String?,
        location: String?
    ) async throws -> [TravelRecommendation]
}

struct EmptyTravelRecommendationService: TravelRecommendationProviding {
    func recommendations(
        for placeName: String?,
        location: String?
    ) async throws -> [TravelRecommendation] {
        []
    }
}
