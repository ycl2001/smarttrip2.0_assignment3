import CoreData
import Foundation

enum TripMemoryMapper {
    nonisolated static func toDomain(
        _ entity: MemoryEntity
    ) throws -> TripMemory {
        let id: UUID = try requiredValue(entity, field: "id")
        let createdAt: Date = try requiredValue(entity, field: "createdAt")
        let trip = try requiredTrip(from: entity)
        let tripID: UUID = try requiredValue(trip, field: "id", entityName: "TripEntity")

        return TripMemory(
            id: id,
            tripID: tripID,
            itineraryItemID: entity.value(forKey: "itineraryItemID") as? UUID,
            location: entity.value(forKey: "location") as? String,
            caption: entity.value(forKey: "caption") as? String,
            photoIdentifier: entity.value(forKey: "photoIdentifier") as? String,
            createdAt: createdAt
        )
    }

    nonisolated static func apply(
        _ memory: TripMemory,
        to entity: MemoryEntity
    ) {
        entity.setValue(memory.id, forKey: "id")
        entity.setValue(memory.itineraryItemID, forKey: "itineraryItemID")
        entity.setValue(memory.location, forKey: "location")
        entity.setValue(memory.caption, forKey: "caption")
        entity.setValue(memory.photoIdentifier, forKey: "photoIdentifier")
        entity.setValue(memory.createdAt, forKey: "createdAt")
    }

    nonisolated static func apply(
        _ memory: TripMemory,
        to entity: MemoryEntity,
        trip: TripEntity
    ) {
        apply(memory, to: entity)
        entity.setValue(trip, forKey: "trip")
    }

    nonisolated private static func requiredTrip(
        from entity: MemoryEntity
    ) throws -> TripEntity {
        guard let trip = entity.value(forKey: "trip") as? TripEntity else {
            throw PersistenceMappingError.missingTripRelationship(
                entity: "MemoryEntity"
            )
        }

        return trip
    }

    nonisolated private static func requiredValue<T>(
        _ entity: NSManagedObject,
        field: String,
        entityName: String = "MemoryEntity"
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
