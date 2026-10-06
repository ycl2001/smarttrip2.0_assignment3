import Foundation

protocol SavedPlaceSchedulingRepository {
    func schedule(
        savedPlaceID: UUID,
        itineraryItem: ItineraryItem
    ) throws
}
