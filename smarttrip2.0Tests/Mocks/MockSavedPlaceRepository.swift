import Foundation
@testable import smarttrip2_0

final class MockSavedPlaceRepository: SavedPlaceRepository {
    var savedPlaces: [SavedPlace]
    var errorToThrow: Error?
    var saveCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0
    var lastSavedPlace: SavedPlace?
    var lastUpdatedSavedPlace: SavedPlace?
    var lastDeletedSavedPlaceID: UUID?

    init(savedPlaces: [SavedPlace] = []) {
        self.savedPlaces = savedPlaces
    }

    func fetchSavedPlaces(
        for tripID: UUID
    ) throws -> [SavedPlace] {
        if let errorToThrow {
            throw errorToThrow
        }

        return savedPlaces.filter { $0.tripID == tripID }
    }

    func fetchSavedPlace(
        id: UUID
    ) throws -> SavedPlace? {
        if let errorToThrow {
            throw errorToThrow
        }

        return savedPlaces.first { $0.id == id }
    }

    func saveSavedPlace(
        _ place: SavedPlace
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        saveCallCount += 1
        lastSavedPlace = place
        savedPlaces.append(place)
    }

    func updateSavedPlace(
        _ place: SavedPlace
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        updateCallCount += 1
        lastUpdatedSavedPlace = place

        if let index = savedPlaces.firstIndex(where: { $0.id == place.id }) {
            savedPlaces[index] = place
        } else {
            savedPlaces.append(place)
        }
    }

    func deleteSavedPlace(
        id: UUID
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        deleteCallCount += 1
        lastDeletedSavedPlaceID = id
        savedPlaces.removeAll { $0.id == id }
    }

    func savedPlaceExists(
        url: URL,
        tripID: UUID
    ) throws -> Bool {
        if let errorToThrow {
            throw errorToThrow
        }

        return savedPlaces.contains { place in
            place.tripID == tripID && place.url == url
        }
    }
}
