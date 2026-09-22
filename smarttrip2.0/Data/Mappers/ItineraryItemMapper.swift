import CoreData
import Foundation

enum ItineraryItemMapper {
    static func toDomain(
        _ entity: ItineraryItemEntity
    ) throws -> ItineraryItem {
        let id: UUID = try requiredValue(entity, field: "id")
        let title: String = try requiredValue(entity, field: "title")
        let location: String = try requiredValue(entity, field: "location")
        let date: Date = try requiredValue(entity, field: "date")
        let startTime: Date = try requiredValue(entity, field: "startTime")
        let categoryRawValue: String = try requiredValue(entity, field: "categoryRawValue")
        let trip = try requiredTrip(from: entity)
        let tripID: UUID = try requiredValue(trip, field: "id", entityName: "TripEntity")

        guard let category = ItineraryCategory(rawValue: categoryRawValue) else {
            throw PersistenceMappingError.invalidItineraryCategory(categoryRawValue)
        }

        return ItineraryItem(
            id: id,
            tripID: tripID,
            title: title,
            location: location,
            date: date,
            startTime: startTime,
            endTime: entity.value(forKey: "endTime") as? Date,
            notes: entity.value(forKey: "notes") as? String,
            category: category
        )
    }

    static func apply(
        _ item: ItineraryItem,
        to entity: ItineraryItemEntity
    ) {
        entity.setValue(item.id, forKey: "id")
        entity.setValue(item.title, forKey: "title")
        entity.setValue(item.location, forKey: "location")
        entity.setValue(item.date, forKey: "date")
        entity.setValue(item.startTime, forKey: "startTime")
        entity.setValue(item.endTime, forKey: "endTime")
        entity.setValue(item.notes, forKey: "notes")
        entity.setValue(item.category.rawValue, forKey: "categoryRawValue")
    }

    static func apply(
        _ item: ItineraryItem,
        to entity: ItineraryItemEntity,
        trip: TripEntity
    ) {
        apply(item, to: entity)
        entity.setValue(trip, forKey: "trip")
    }

    private static func requiredTrip(
        from entity: ItineraryItemEntity
    ) throws -> TripEntity {
        guard let trip = entity.value(forKey: "trip") as? TripEntity else {
            throw PersistenceMappingError.missingTripRelationship(
                entity: "ItineraryItemEntity"
            )
        }

        return trip
    }

    private static func requiredValue<T>(
        _ entity: NSManagedObject,
        field: String,
        entityName: String = "ItineraryItemEntity"
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
