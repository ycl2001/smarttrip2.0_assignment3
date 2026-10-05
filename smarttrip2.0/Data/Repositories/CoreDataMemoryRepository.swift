import CoreData
import Foundation

final class CoreDataMemoryRepository: MemoryRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchMemories(
        for tripID: UUID
    ) throws -> [TripMemory] {
        let request = MemoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "trip.id == %@", tripID as CVarArg)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        let entities = try context.fetch(request)
        return try entities.map(TripMemoryMapper.toDomain)
    }

    func saveMemory(
        _ memory: TripMemory
    ) throws {
        let trip = try requiredTripEntity(id: memory.tripID)
        let entity = MemoryEntity(context: context)
        TripMemoryMapper.apply(memory, to: entity, trip: trip)
        try saveContextIfNeeded()
    }

    func deleteMemory(
        id: UUID
    ) throws {
        guard let entity = try fetchMemoryEntity(id: id) else {
            return
        }

        context.delete(entity)
        try saveContextIfNeeded()
    }

    private func fetchMemoryEntity(
        id: UUID
    ) throws -> MemoryEntity? {
        let request = MemoryEntity.fetchRequest()
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
