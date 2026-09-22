import Foundation

protocol TripRepository {
    func fetchTrips() throws -> [Trip]

    func fetchTrip(
        id: UUID
    ) throws -> Trip?

    func saveTrip(
        _ trip: Trip
    ) throws

    func updateTrip(
        _ trip: Trip
    ) throws

    func deleteTrip(
        id: UUID
    ) throws
}
