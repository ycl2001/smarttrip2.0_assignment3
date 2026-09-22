import Foundation

enum CaptureSharedPlaceError: Error, Equatable {
    case tripNotFound
    case missingPlaceName
    case placeAlreadySaved
}
