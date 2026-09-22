import Foundation

/// Represents a place or activity discovered by a traveller before it is committed to the itinerary.
struct SavedPlace: Identifiable, Equatable {
    let id: UUID
    let tripID: UUID
    let name: String
    let url: URL?
    let notes: String?
    let status: SavedPlaceStatus
    let dateSaved: Date

    nonisolated init(
        id: UUID = UUID(),
        tripID: UUID,
        name: String,
        url: URL? = nil,
        notes: String? = nil,
        status: SavedPlaceStatus = .idea,
        dateSaved: Date = Date()
    ) {
        self.id = id
        self.tripID = tripID
        self.name = name
        self.url = url
        self.notes = notes
        self.status = status
        self.dateSaved = dateSaved
    }
}
