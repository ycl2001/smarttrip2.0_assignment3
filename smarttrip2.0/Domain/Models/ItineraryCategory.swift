import Foundation

/// Represents the domain category of a confirmed trip activity.
enum ItineraryCategory: String, Codable, CaseIterable {
    case attraction
    case food
    case transport
    case accommodation
    case shopping
    case activity
    case other
}
