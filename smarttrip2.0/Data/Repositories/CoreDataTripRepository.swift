import CoreData
import Foundation

final class CoreDataTripRepository: TripRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchTrips() throws -> [Trip] {
        let request = TripEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "startDate", ascending: true)
        ]

        let entities = try context.fetch(request)
        return try entities.map(TripMapper.toDomain)
    }

    func fetchTrip(
        id: UUID
    ) throws -> Trip? {
        guard let entity = try fetchTripEntity(id: id) else {
            return nil
        }

        return try TripMapper.toDomain(entity)
    }

    func saveTrip(
        _ trip: Trip
    ) throws {
        let entity = TripEntity(context: context)
        TripMapper.apply(trip, to: entity)
        try saveContextIfNeeded()
    }

    func updateTrip(
        _ trip: Trip
    ) throws {
        let entity = try fetchTripEntity(id: trip.id) ?? TripEntity(context: context)
        TripMapper.apply(trip, to: entity)
        try saveContextIfNeeded()
    }

    func deleteTrip(
        id: UUID
    ) throws {
        guard let entity = try fetchTripEntity(id: id) else {
            return
        }

        context.delete(entity)
        try saveContextIfNeeded()
    }

    private func fetchTripEntity(
        id: UUID
    ) throws -> TripEntity? {
        let request = TripEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        return try context.fetch(request).first
    }

    private func saveContextIfNeeded() throws {
        guard context.hasChanges else {
            return
        }

        try context.save()
    }
}
