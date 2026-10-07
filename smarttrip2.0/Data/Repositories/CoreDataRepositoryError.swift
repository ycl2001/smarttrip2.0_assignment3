import Foundation

enum CoreDataRepositoryError: Error {
    case tripNotFound(UUID)
    case itineraryItemNotFound(UUID)
    case savedPlaceNotFound(UUID)
    case persistentStoreUnavailable
}
