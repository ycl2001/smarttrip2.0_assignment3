import CoreData
import SwiftUI

struct SmartTripDependencies {
    let tripRepository: any TripRepository
    let savedPlaceRepository: any SavedPlaceRepository
    let itineraryRepository: any ItineraryRepository
    let createTripUseCase: CreateTripUseCase

    init(context: NSManagedObjectContext) {
        let tripRepository = CoreDataTripRepository(context: context)
        let savedPlaceRepository = CoreDataSavedPlaceRepository(context: context)
        let itineraryRepository = CoreDataItineraryRepository(context: context)

        self.tripRepository = tripRepository
        self.savedPlaceRepository = savedPlaceRepository
        self.itineraryRepository = itineraryRepository
        self.createTripUseCase = CreateTripUseCase(
            tripRepository: tripRepository
        )
    }

    func makeTripViewModel() -> TripViewModel {
        TripViewModel(
            createTripUseCase: createTripUseCase,
            tripRepository: tripRepository
        )
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
