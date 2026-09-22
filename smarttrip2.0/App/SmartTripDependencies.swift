import CoreData
import SwiftUI

struct SmartTripDependencies {
    let tripRepository: any TripRepository
    let savedPlaceRepository: any SavedPlaceRepository
    let itineraryRepository: any ItineraryRepository

    init(context: NSManagedObjectContext) {
        self.tripRepository = CoreDataTripRepository(context: context)
        self.savedPlaceRepository = CoreDataSavedPlaceRepository(context: context)
        self.itineraryRepository = CoreDataItineraryRepository(context: context)
    }
}

private struct SmartTripDependenciesKey: EnvironmentKey {
    static let defaultValue: SmartTripDependencies? = nil
}

extension EnvironmentValues {
    var smartTripDependencies: SmartTripDependencies? {
        get { self[SmartTripDependenciesKey.self] }
        set { self[SmartTripDependenciesKey.self] = newValue }
    }
}
