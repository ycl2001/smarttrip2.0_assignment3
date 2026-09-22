import CoreData
import Foundation

enum SavedPlaceMapper {
    nonisolated static func toDomain(
        _ entity: SavedPlaceEntity
    ) throws -> SavedPlace {
        let id: UUID = try requiredValue(entity, field: "id")
        let name: String = try requiredValue(entity, field: "name")
        let statusRawValue: String = try requiredValue(entity, field: "statusRawValue")
        let dateSaved: Date = try requiredValue(entity, field: "dateSaved")
        let trip = try requiredTrip(from: entity)
        let tripID: UUID = try requiredValue(trip, field: "id", entityName: "TripEntity")

        guard let status = SavedPlaceStatus(rawValue: statusRawValue) else {
            throw PersistenceMappingError.invalidSavedPlaceStatus(statusRawValue)
        }

        let urlString = entity.value(forKey: "urlString") as? String
        let url = try urlString.map { urlString throws -> URL in
            guard let url = URL(string: urlString) else {
                throw PersistenceMappingError.invalidURL(urlString)
            }

            return url
        }

        return SavedPlace(
            id: id,
            tripID: tripID,
            name: name,
            url: url,
            notes: entity.value(forKey: "notes") as? String,
            status: status,
            dateSaved: dateSaved
        )
    }

    nonisolated static func apply(
        _ place: SavedPlace,
        to entity: SavedPlaceEntity
    ) {
        entity.setValue(place.id, forKey: "id")
        entity.setValue(place.name, forKey: "name")
        entity.setValue(place.url?.absoluteString, forKey: "urlString")
        entity.setValue(place.notes, forKey: "notes")
        entity.setValue(place.status.rawValue, forKey: "statusRawValue")
        entity.setValue(place.dateSaved, forKey: "dateSaved")
    }

    nonisolated static func apply(
        _ place: SavedPlace,
        to entity: SavedPlaceEntity,
        trip: TripEntity
    ) {
        apply(place, to: entity)
        entity.setValue(trip, forKey: "trip")
    }

    nonisolated private static func requiredTrip(
        from entity: SavedPlaceEntity
    ) throws -> TripEntity {
        guard let trip = entity.value(forKey: "trip") as? TripEntity else {
            throw PersistenceMappingError.missingTripRelationship(
                entity: "SavedPlaceEntity"
            )
        }

        return trip
    }

    nonisolated private static func requiredValue<T>(
        _ entity: NSManagedObject,
        field: String,
        entityName: String = "SavedPlaceEntity"
    ) throws -> T {
        guard let value = entity.value(forKey: field) as? T else {
            throw PersistenceMappingError.missingRequiredField(
                entity: entityName,
                field: field
            )
        }

        return value
    }
}
