import Foundation

/// Represents the planning state of a discovered place.
enum SavedPlaceStatus: String, Codable, CaseIterable {
    case idea
    case shortlisted
    case scheduled
    case rejected
}
