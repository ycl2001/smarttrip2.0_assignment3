import CoreData
import Foundation

final class CoreDataSavedPlaceRepository: SavedPlaceRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchSavedPlaces(
        for tripID: UUID
    ) throws -> [SavedPlace] {
        let request = SavedPlaceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "trip.id == %@", tripID as CVarArg)
        request.sortDescriptors = [
            NSSortDescriptor(key: "dateSaved", ascending: false)
        ]

        let entities = try context.fetch(request)
        return try entities.map(SavedPlaceMapper.toDomain)
    }

    func saveSavedPlace(
        _ place: SavedPlace
    ) throws {
        let trip = try requiredTripEntity(id: place.tripID)
        let entity = SavedPlaceEntity(context: context)
        SavedPlaceMapper.apply(place, to: entity, trip: trip)
        try saveContextIfNeeded()
    }

    func updateSavedPlace(
        _ place: SavedPlace
    ) throws {
        let trip = try requiredTripEntity(id: place.tripID)
        let entity = try fetchSavedPlaceEntity(id: place.id) ?? SavedPlaceEntity(context: context)
        SavedPlaceMapper.apply(place, to: entity, trip: trip)
        try saveContextIfNeeded()
    }

    func deleteSavedPlace(
        id: UUID
    ) throws {
        guard let entity = try fetchSavedPlaceEntity(id: id) else {
            return
        }

        context.delete(entity)
        try saveContextIfNeeded()
    }

    func savedPlaceExists(
        url: URL,
        tripID: UUID
    ) throws -> Bool {
        let request = SavedPlaceEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "urlString == %@ AND trip.id == %@",
            url.absoluteString,
            tripID as CVarArg
        )

        return try context.count(for: request) > 0
    }

    private func fetchSavedPlaceEntity(
        id: UUID
    ) throws -> SavedPlaceEntity? {
        let request = SavedPlaceEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        return try context.fetch(request).first
    }

    private func requiredTripEntity(
        id: UUID
    ) throws -> TripEntity {
        let request = TripEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let trip = try context.fetch(request).first else {
            throw PersistenceMappingError.missingRequiredField(
                entity: "TripEntity",
                field: "id"
            )
        }

        return trip
    }

    private func saveContextIfNeeded() throws {
        guard context.hasChanges else {
            return
        }

        try context.save()
    }
}
