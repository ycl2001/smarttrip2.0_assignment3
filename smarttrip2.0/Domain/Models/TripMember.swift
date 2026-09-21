import Foundation

/// Represents a traveller's role within a trip.
enum TripMemberRole: String, Codable {
    case organiser
    case member
}

/// Represents a traveller participating in a trip.
struct TripMember: Identifiable, Equatable {
    let id: UUID
    let tripID: UUID
    let name: String
    let role: TripMemberRole

    init(
        id: UUID = UUID(),
        tripID: UUID,
        name: String,
        role: TripMemberRole = .member
    ) {
        self.id = id
        self.tripID = tripID
        self.name = name
        self.role = role
    }
}
