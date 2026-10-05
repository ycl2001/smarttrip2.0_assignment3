import Foundation

struct ActionTravelInput: Identifiable, Equatable {
    let id: UUID
    let sourceURL: URL?
    let sharedText: String?
    let sourceTitle: String?
    let receivedAt: Date

    init(
        id: UUID = UUID(),
        sourceURL: URL? = nil,
        sharedText: String? = nil,
        sourceTitle: String? = nil,
        receivedAt: Date = Date()
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.sharedText = sharedText
        self.sourceTitle = sourceTitle
        self.receivedAt = receivedAt
    }
}

enum ActionInputError: LocalizedError, Equatable {
    case noSupportedContent
    case unableToReadContent

    var errorDescription: String? {
        switch self {
        case .noSupportedContent:
            "SmartTrip could not find a URL or text to process."
        case .unableToReadContent:
            "SmartTrip could not read the shared content."
        }
    }
}
