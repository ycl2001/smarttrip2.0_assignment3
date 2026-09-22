import Foundation

enum ScheduleSavedPlaceError: Error, Equatable {
    case tripNotFound
    case savedPlaceNotFound
    case alreadyScheduled
    case outsideTripDates
    case missingSchedule
}
