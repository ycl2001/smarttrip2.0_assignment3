import Foundation

enum CaptureJourneyMemoryError: Error, Equatable, LocalizedError {
    case tripNotFound
    case emptyMemory
    case invalidCaptureDate

    var errorDescription: String? {
        switch self {
        case .tripNotFound:
            "We couldn't find this trip."
        case .emptyMemory:
            "Add a memory note, location, or photo before saving."
        case .invalidCaptureDate:
            "Choose a valid capture date."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .tripNotFound:
            "Return to your Trips and choose an existing trip before adding a memory."
        case .emptyMemory:
            "Write a short reflection, add a place, or attach a photo reference."
        case .invalidCaptureDate:
            "Use the date and time when this moment was captured."
        }
    }
}
