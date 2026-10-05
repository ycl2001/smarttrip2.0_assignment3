import Foundation

struct TravelDiscoveryResult: Identifiable, Equatable {
    let id: UUID
    let sourceURL: URL?
    var placeName: String?
    var location: String?
    var summary: String
    var recommendations: [TravelRecommendation]

    init(
        id: UUID = UUID(),
        sourceURL: URL?,
        placeName: String?,
        location: String?,
        summary: String,
        recommendations: [TravelRecommendation] = []
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.placeName = placeName
        self.location = location
        self.summary = summary
        self.recommendations = recommendations
    }
}

struct TravelRecommendation: Identifiable, Equatable {
    let id: UUID
    let name: String
    let subtitle: String?
    let category: String?

    init(
        id: UUID = UUID(),
        name: String,
        subtitle: String? = nil,
        category: String? = nil
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.category = category
    }
}

enum TravelContentProcessingError: LocalizedError, Equatable {
    case emptyInput
    case unsupportedContent

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            "SmartTrip could not find enough travel information to process."
        case .unsupportedContent:
            "SmartTrip can process shared URLs and plain text."
        }
    }
}
