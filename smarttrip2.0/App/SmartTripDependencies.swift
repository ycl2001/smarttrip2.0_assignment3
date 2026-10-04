import CoreData
import SwiftUI

struct SmartTripDependencies {
    let tripRepository: any TripRepository
    let savedPlaceRepository: any SavedPlaceRepository
    let itineraryRepository: any ItineraryRepository
    let createTripUseCase: CreateTripUseCase
    let captureSharedPlaceUseCase: CaptureSharedPlaceUseCase
    let scheduleSavedPlaceUseCase: ScheduleSavedPlaceUseCase

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
        self.captureSharedPlaceUseCase = CaptureSharedPlaceUseCase(
            tripRepository: tripRepository,
            savedPlaceRepository: savedPlaceRepository
        )
        self.scheduleSavedPlaceUseCase = ScheduleSavedPlaceUseCase(
            tripRepository: tripRepository,
            savedPlaceRepository: savedPlaceRepository,
            itineraryRepository: itineraryRepository
        )
    }

    func makeTripViewModel() -> TripViewModel {
        TripViewModel(
            createTripUseCase: createTripUseCase,
            tripRepository: tripRepository
        )
    }

    func makeSavedPlaceViewModel() -> SavedPlaceViewModel {
        SavedPlaceViewModel(
            captureSharedPlaceUseCase: captureSharedPlaceUseCase,
            scheduleSavedPlaceUseCase: scheduleSavedPlaceUseCase,
            savedPlaceRepository: savedPlaceRepository
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
