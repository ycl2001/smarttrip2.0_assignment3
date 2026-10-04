import Foundation

enum CaptureSharedPlaceError: Error, Equatable, LocalizedError {
    case tripNotFound
    case missingPlaceName
    case placeAlreadySaved

    var errorDescription: String? {
        switch self {
        case .tripNotFound:
            "We couldn't find this trip."
        case .missingPlaceName:
            "This place needs a name."
        case .placeAlreadySaved:
            "This place is already saved to this trip."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .tripNotFound:
            "Return to your Trips and choose an existing trip before saving this place."
        case .missingPlaceName:
            "Add a name so your group can identify it in Saved Places."
        case .placeAlreadySaved:
            "Check Saved Places before adding it again."
        }
    }
}
