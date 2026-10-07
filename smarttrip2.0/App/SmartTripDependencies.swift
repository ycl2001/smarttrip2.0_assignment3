import CoreData
import SwiftUI

struct SmartTripDependencies {
    let tripRepository: any TripRepository
    let savedPlaceRepository: any SavedPlaceRepository
    let itineraryRepository: any ItineraryRepository
    let memoryRepository: any MemoryRepository
    let createTripUseCase: CreateTripUseCase
    let captureSharedPlaceUseCase: CaptureSharedPlaceUseCase
    let scheduleSavedPlaceUseCase: ScheduleSavedPlaceUseCase
    let captureJourneyMemoryUseCase: CaptureJourneyMemoryUseCase
    let journeyCapsuleNotificationAuthorizer: any JourneyCapsuleNotificationAuthorizing
    let journeyCapsuleNotificationScheduler: any JourneyCapsuleNotificationScheduling
    let currentLocationService: any CurrentLocationProviding

    init(context: NSManagedObjectContext) {
        let tripRepository = CoreDataTripRepository(context: context)
        let savedPlaceRepository = CoreDataSavedPlaceRepository(context: context)
        let itineraryRepository = CoreDataItineraryRepository(context: context)
        let schedulingRepository = CoreDataSavedPlaceSchedulingRepository(context: context)
        let memoryRepository = CoreDataMemoryRepository(context: context)
        let journeyCapsuleNotificationAuthorizer = JourneyCapsuleNotificationAuthorizer()
        let journeyCapsuleNotificationScheduler = JourneyCapsuleNotificationScheduler()
        let currentLocationService = CurrentLocationService()

        self.tripRepository = tripRepository
        self.savedPlaceRepository = savedPlaceRepository
        self.itineraryRepository = itineraryRepository
        self.memoryRepository = memoryRepository
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
            schedulingRepository: schedulingRepository
        )
        self.captureJourneyMemoryUseCase = CaptureJourneyMemoryUseCase(
            tripRepository: tripRepository,
            memoryRepository: memoryRepository
        )
        self.journeyCapsuleNotificationAuthorizer = journeyCapsuleNotificationAuthorizer
        self.journeyCapsuleNotificationScheduler = journeyCapsuleNotificationScheduler
        self.currentLocationService = currentLocationService
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

    func makeSavedPlacesOverviewViewModel() -> SavedPlacesOverviewViewModel {
        SavedPlacesOverviewViewModel(
            tripRepository: tripRepository,
            savedPlaceRepository: savedPlaceRepository
        )
    }

    func makeTripHubViewModel(
        tripID: UUID
    ) -> TripHubViewModel {
        TripHubViewModel(
            tripID: tripID,
            savedPlaceRepository: savedPlaceRepository,
            itineraryRepository: itineraryRepository
        )
    }

    func makeItineraryViewModel(
        tripID: UUID
    ) -> ItineraryViewModel {
        ItineraryViewModel(
            tripID: tripID,
            itineraryRepository: itineraryRepository
        )
    }

    func makeJourneyCapsuleViewModel(
        tripID: UUID
    ) -> JourneyCapsuleViewModel {
        JourneyCapsuleViewModel(
            tripID: tripID,
            memoryRepository: memoryRepository,
            captureJourneyMemoryUseCase: captureJourneyMemoryUseCase,
            notificationAuthorizer: journeyCapsuleNotificationAuthorizer,
            notificationScheduler: journeyCapsuleNotificationScheduler,
            placeAutocomplete: MapKitPlaceAutocompleteService(),
            currentLocation: currentLocationService
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
