import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    private(set) var storeLoadError: Error?

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SmartTripModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true

        container.loadPersistentStores { _, error in
            if let error {
                self.storeLoadError = error
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
