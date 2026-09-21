import Foundation

/// Represents a memory associated with a trip or a specific itinerary activity.
struct TripMemory: Identifiable, Equatable {
    let id: UUID
    let tripID: UUID
    let itineraryItemID: UUID?
    let caption: String?
    let photoIdentifier: String?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        tripID: UUID,
        itineraryItemID: UUID? = nil,
        caption: String? = nil,
        photoIdentifier: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.tripID = tripID
        self.itineraryItemID = itineraryItemID
        self.caption = caption
        self.photoIdentifier = photoIdentifier
        self.createdAt = createdAt
    }
}
