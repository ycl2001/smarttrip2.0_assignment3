import Foundation

enum CreateTripError: Error, Equatable {
    case missingTripName
    case missingDestination
    case invalidTravelDates
}
