import Foundation

/// Represents a memory associated with a trip or a specific itinerary activity.
struct TripMemory: Identifiable, Equatable {
    let id: UUID
    let tripID: UUID
    let itineraryItemID: UUID?
    let location: String?
    let caption: String?
    let photoIdentifier: String?
    let createdAt: Date

    nonisolated init(
        id: UUID = UUID(),
        tripID: UUID,
        itineraryItemID: UUID? = nil,
        location: String? = nil,
        caption: String? = nil,
        photoIdentifier: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.tripID = tripID
        self.itineraryItemID = itineraryItemID
        self.location = location
        self.caption = caption
        self.photoIdentifier = photoIdentifier
        self.createdAt = createdAt
    }
}
