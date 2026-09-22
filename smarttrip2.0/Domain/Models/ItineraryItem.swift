import Foundation

/// Represents a confirmed and scheduled activity within a trip.
struct ItineraryItem: Identifiable, Equatable {
    let id: UUID
    let tripID: UUID
    let sourceSavedPlaceID: UUID?
    let title: String
    let location: String
    let date: Date
    let startTime: Date?
    let endTime: Date?
    let notes: String?
    let category: ItineraryCategory

    nonisolated init(
        id: UUID = UUID(),
        tripID: UUID,
        sourceSavedPlaceID: UUID? = nil,
        title: String,
        location: String,
        date: Date,
        startTime: Date? = nil,
        endTime: Date? = nil,
        notes: String? = nil,
        category: ItineraryCategory = .other
    ) {
        self.id = id
        self.tripID = tripID
        self.sourceSavedPlaceID = sourceSavedPlaceID
        self.title = title
        self.location = location
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
        self.category = category
    }
}
