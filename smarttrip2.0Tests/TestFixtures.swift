import Foundation
@testable import smarttrip2_0

enum TestDates {
    static let calendar = Calendar(identifier: .gregorian)

    static let december10 = makeDate(day: 10)
    static let december12 = makeDate(day: 12)
    static let december12At10 = makeDate(day: 12, hour: 10)
    static let december15 = makeDate(day: 15)
    static let december16 = makeDate(day: 16)
    static let december16At10 = makeDate(day: 16, hour: 10)

    private static func makeDate(
        day: Int,
        hour: Int = 9
    ) -> Date {
        calendar.date(
            from: DateComponents(
                year: 2026,
                month: 12,
                day: day,
                hour: hour
            )
        )!
    }
}

enum TestFixtures {
    static func trip(
        id: UUID = UUID(),
        name: String = "Tokyo Graduation Trip",
        destination: String = "Tokyo"
    ) -> Trip {
        Trip(
            id: id,
            name: name,
            destination: destination,
            startDate: TestDates.december10,
            endDate: TestDates.december15
        )
    }

    static func savedPlace(
        id: UUID = UUID(),
        tripID: UUID,
        name: String = "TeamLab Planets",
        url: URL? = nil,
        status: SavedPlaceStatus = .idea
    ) -> SavedPlace {
        SavedPlace(
            id: id,
            tripID: tripID,
            name: name,
            url: url,
            notes: "Book ahead",
            status: status,
            dateSaved: TestDates.december10
        )
    }
}
