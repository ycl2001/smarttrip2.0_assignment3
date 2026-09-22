import CoreData
import Foundation

final class CoreDataItineraryRepository: ItineraryRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchItineraryItems(
        for tripID: UUID
    ) throws -> [ItineraryItem] {
        let request = ItineraryItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "trip.id == %@", tripID as CVarArg)
        request.sortDescriptors = chronologicalSortDescriptors

        let entities = try context.fetch(request)
        return try entities.map(ItineraryItemMapper.toDomain)
    }

    func saveItineraryItem(
        _ item: ItineraryItem
    ) throws {
        let trip = try requiredTripEntity(id: item.tripID)
        let entity = ItineraryItemEntity(context: context)
        ItineraryItemMapper.apply(item, to: entity, trip: trip)
        try saveContextIfNeeded()
    }

    func updateItineraryItem(
        _ item: ItineraryItem
    ) throws {
        guard let entity = try fetchItineraryItemEntity(id: item.id) else {
            throw CoreDataRepositoryError.itineraryItemNotFound(item.id)
        }

        let trip = try requiredTripEntity(id: item.tripID)
        ItineraryItemMapper.apply(item, to: entity, trip: trip)
        try saveContextIfNeeded()
    }

    func deleteItineraryItem(
        id: UUID
    ) throws {
        guard let entity = try fetchItineraryItemEntity(id: id) else {
            return
        }

        context.delete(entity)
        try saveContextIfNeeded()
    }

    func fetchUpcomingItems(
        for tripID: UUID,
        from date: Date
    ) throws -> [ItineraryItem] {
        let request = ItineraryItemEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "trip.id == %@ AND startTime >= %@",
            tripID as CVarArg,
            date as NSDate
        )
        request.sortDescriptors = chronologicalSortDescriptors

        let entities = try context.fetch(request)
        return try entities.map(ItineraryItemMapper.toDomain)
    }

    private var chronologicalSortDescriptors: [NSSortDescriptor] {
        [
            NSSortDescriptor(key: "date", ascending: true),
            NSSortDescriptor(key: "startTime", ascending: true)
        ]
    }

    private func fetchItineraryItemEntity(
        id: UUID
    ) throws -> ItineraryItemEntity? {
        let request = ItineraryItemEntity.fetchRequest()
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
            throw CoreDataRepositoryError.tripNotFound(id)
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
