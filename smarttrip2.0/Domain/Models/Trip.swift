import Foundation

/// Represents the overall journey being planned by a travel group.
struct Trip: Identifiable, Equatable {
    let id: UUID
    let name: String
    let destination: String
    let startDate: Date
    let endDate: Date
    let coverImageName: String?

    nonisolated init(
        id: UUID = UUID(),
        name: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        coverImageName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.coverImageName = coverImageName
    }
}
