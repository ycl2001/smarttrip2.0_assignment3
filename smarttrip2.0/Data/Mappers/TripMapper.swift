import CoreData
import Foundation

enum TripMapper {
    static func toDomain(
        _ entity: TripEntity
    ) throws -> Trip {
        let id: UUID = try requiredValue(entity, field: "id")
        let name: String = try requiredValue(entity, field: "name")
        let destination: String = try requiredValue(entity, field: "destination")
        let startDate: Date = try requiredValue(entity, field: "startDate")
        let endDate: Date = try requiredValue(entity, field: "endDate")

        return Trip(
            id: id,
            name: name,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            coverImageName: entity.value(forKey: "coverImageName") as? String
        )
    }

    static func apply(
        _ trip: Trip,
        to entity: TripEntity
    ) {
        entity.setValue(trip.id, forKey: "id")
        entity.setValue(trip.name, forKey: "name")
        entity.setValue(trip.destination, forKey: "destination")
        entity.setValue(trip.startDate, forKey: "startDate")
        entity.setValue(trip.endDate, forKey: "endDate")
        entity.setValue(trip.coverImageName, forKey: "coverImageName")
    }

    private static func requiredValue<T>(
        _ entity: NSManagedObject,
        field: String
    ) throws -> T {
        guard let value = entity.value(forKey: field) as? T else {
            throw PersistenceMappingError.missingRequiredField(
                entity: "TripEntity",
                field: field
            )
        }

        return value
    }
}
