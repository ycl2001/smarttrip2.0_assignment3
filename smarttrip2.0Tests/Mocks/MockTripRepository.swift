import Foundation
@testable import smarttrip2_0

final class MockTripRepository: TripRepository {
    var trips: [Trip]
    var errorToThrow: Error?
    var saveCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0
    var lastSavedTrip: Trip?
    var lastUpdatedTrip: Trip?
    var lastDeletedTripID: UUID?

    init(trips: [Trip] = []) {
        self.trips = trips
    }

    func fetchTrips() throws -> [Trip] {
        if let errorToThrow {
            throw errorToThrow
        }

        return trips
    }

    func fetchTrip(
        id: UUID
    ) throws -> Trip? {
        if let errorToThrow {
            throw errorToThrow
        }

        return trips.first { $0.id == id }
    }

    func saveTrip(
        _ trip: Trip
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        saveCallCount += 1
        lastSavedTrip = trip
        trips.append(trip)
    }

    func updateTrip(
        _ trip: Trip
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        updateCallCount += 1
        lastUpdatedTrip = trip

        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
        } else {
            trips.append(trip)
        }
    }

    func deleteTrip(
        id: UUID
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        deleteCallCount += 1
        lastDeletedTripID = id
        trips.removeAll { $0.id == id }
    }
}
