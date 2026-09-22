import Foundation

enum CoreDataRepositoryError: Error {
    case tripNotFound(UUID)
    case itineraryItemNotFound(UUID)
    case upcomingItineraryQueryNotConfigured
}
