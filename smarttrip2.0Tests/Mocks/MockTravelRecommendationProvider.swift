import Foundation

struct MockTravelRecommendationProvider: TravelRecommendationProviding {
    var recommendationsToReturn: [TravelRecommendation] = []
    var errorToThrow: Error?

    func recommendations(
        for placeName: String?,
        location: String?
    ) async throws -> [TravelRecommendation] {
        if let errorToThrow {
            throw errorToThrow
        }

        return recommendationsToReturn
    }
}
