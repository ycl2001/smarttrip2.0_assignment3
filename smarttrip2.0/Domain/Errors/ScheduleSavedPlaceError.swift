import Foundation

enum ScheduleSavedPlaceError: Error, Equatable, LocalizedError {
    case tripNotFound
    case savedPlaceNotFound
    case alreadyScheduled
    case outsideTripDates
    case missingSchedule

    var errorDescription: String? {
        switch self {
        case .tripNotFound:
            "We couldn't find the trip for this place."
        case .savedPlaceNotFound:
            "We couldn't find this saved place."
        case .alreadyScheduled:
            "This place is already in your itinerary."
        case .outsideTripDates:
            "This activity falls outside your trip dates."
        case .missingSchedule:
            "This activity needs a valid schedule."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .tripNotFound:
            "Return to your Trips and select the correct trip before scheduling it."
        case .savedPlaceNotFound:
            "Refresh Saved Places or add the place again before scheduling it."
        case .alreadyScheduled:
            "Open the itinerary if you want to change its date or time."
        case .outsideTripDates:
            "Choose a date between the trip's start and end dates."
        case .missingSchedule:
            "Choose a date and start time before adding it to the itinerary."
        }
    }
}
