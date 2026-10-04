import Foundation

enum CreateTripError: Error, Equatable, LocalizedError {
    case missingTripName
    case missingDestination
    case invalidTravelDates

    var errorDescription: String? {
        switch self {
        case .missingTripName:
            "Your trip needs a name."
        case .missingDestination:
            "Your trip needs a destination."
        case .invalidTravelDates:
            "The trip cannot end before it starts."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .missingTripName:
            "Add a name your group can recognise, such as 'Tokyo Graduation Trip'."
        case .missingDestination:
            "Add the main destination before creating the trip."
        case .invalidTravelDates:
            "Choose an end date that is the same as or later than the start date."
        }
    }
}
