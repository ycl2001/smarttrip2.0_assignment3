import Foundation

protocol SavedPlaceRepository {
    func fetchSavedPlaces(
        for tripID: UUID
    ) throws -> [SavedPlace]

    func saveSavedPlace(
        _ place: SavedPlace
    ) throws

    func updateSavedPlace(
        _ place: SavedPlace
    ) throws

    func deleteSavedPlace(
        id: UUID
    ) throws

    func savedPlaceExists(
        url: URL,
        tripID: UUID
    ) throws -> Bool
}
