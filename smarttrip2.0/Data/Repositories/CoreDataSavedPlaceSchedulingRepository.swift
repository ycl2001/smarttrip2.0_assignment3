import CoreData
import Foundation

final class CoreDataSavedPlaceSchedulingRepository: SavedPlaceSchedulingRepository {
    private let viewContext: NSManagedObjectContext
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator?

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        self.persistentStoreCoordinator = context.persistentStoreCoordinator
    }

    func schedule(
        savedPlaceID: UUID,
        itineraryItem: ItineraryItem
    ) throws {
        guard let persistentStoreCoordinator else {
            throw CoreDataRepositoryError.persistentStoreUnavailable
        }

        let transactionContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType
        )
        transactionContext.persistentStoreCoordinator = persistentStoreCoordinator

        var transactionError: Error?
        var saveNotification: Notification?
        let observer = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: transactionContext,
            queue: nil
        ) { notification in
            saveNotification = notification
        }
        defer {
            NotificationCenter.default.removeObserver(observer)
        }

        transactionContext.performAndWait {
            do {
                let savedPlace = try requiredSavedPlaceEntity(
                    id: savedPlaceID,
                    in: transactionContext
                )
                let trip = try requiredTripEntity(
                    id: itineraryItem.tripID,
                    in: transactionContext
                )
                let itineraryItemEntity = ItineraryItemEntity(context: transactionContext)

                ItineraryItemMapper.apply(
                    itineraryItem,
                    to: itineraryItemEntity,
                    trip: trip
                )
                savedPlace.setValue(
                    SavedPlaceStatus.scheduled.rawValue,
                    forKey: "statusRawValue"
                )

                try transactionContext.save()
            } catch {
                transactionContext.rollback()
                transactionError = error
            }
        }

        if let transactionError {
            throw transactionError
        }

        if let saveNotification {
            viewContext.performAndWait {
                viewContext.mergeChanges(fromContextDidSave: saveNotification)
            }
        }
    }

    private func requiredSavedPlaceEntity(
        id: UUID,
        in context: NSManagedObjectContext
    ) throws -> SavedPlaceEntity {
        let request = SavedPlaceEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let savedPlace = try context.fetch(request).first else {
            throw CoreDataRepositoryError.savedPlaceNotFound(id)
        }

        return savedPlace
    }

    private func requiredTripEntity(
        id: UUID,
        in context: NSManagedObjectContext
    ) throws -> TripEntity {
        let request = TripEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let trip = try context.fetch(request).first else {
            throw CoreDataRepositoryError.tripNotFound(id)
        }

        return trip
    }
}
