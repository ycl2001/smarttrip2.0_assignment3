import CoreData
import Foundation
import Testing
@testable import smarttrip2_0

@MainActor
struct CoreDataPersistenceValidationTests {
    @Test func tripRepositoryPersistsCreateReadUpdateAndDelete() throws {
        let repositories = makeRepositories()
        let trip = TestFixtures.trip(name: "Tokyo Trip", destination: "Tokyo")

        try repositories.tripRepository.saveTrip(trip)

        var fetchedTrip = try #require(try repositories.tripRepository.fetchTrip(id: trip.id))
        #expect(fetchedTrip.name == "Tokyo Trip")
        #expect(try repositories.tripRepository.fetchTrips().contains(trip))

        let updatedTrip = Trip(
            id: trip.id,
            name: "Tokyo Food Trip",
            destination: trip.destination,
            startDate: trip.startDate,
            endDate: trip.endDate,
            coverImageName: trip.coverImageName
        )

        try repositories.tripRepository.updateTrip(updatedTrip)

        fetchedTrip = try #require(try repositories.tripRepository.fetchTrip(id: trip.id))
        #expect(fetchedTrip.name == "Tokyo Food Trip")

        try repositories.tripRepository.deleteTrip(id: trip.id)

        #expect(try repositories.tripRepository.fetchTrip(id: trip.id) == nil)
        #expect(try repositories.tripRepository.fetchTrips().isEmpty)
    }

    @Test func savedPlacesBelongOnlyToTheirTrip() throws {
        let repositories = makeRepositories()
        let tripA = TestFixtures.trip(name: "Tokyo Trip", destination: "Tokyo")
        let tripB = TestFixtures.trip(name: "Kyoto Trip", destination: "Kyoto")
        let placeA = TestFixtures.savedPlace(tripID: tripA.id, name: "TeamLab")
        let placeB = TestFixtures.savedPlace(tripID: tripB.id, name: "Fushimi Inari")

        try repositories.tripRepository.saveTrip(tripA)
        try repositories.tripRepository.saveTrip(tripB)
        try repositories.savedPlaceRepository.saveSavedPlace(placeA)
        try repositories.savedPlaceRepository.saveSavedPlace(placeB)

        let tripAPlaces = try repositories.savedPlaceRepository.fetchSavedPlaces(for: tripA.id)
        let tripBPlaces = try repositories.savedPlaceRepository.fetchSavedPlaces(for: tripB.id)

        #expect(tripAPlaces.map(\.id) == [placeA.id])
        #expect(tripBPlaces.map(\.id) == [placeB.id])
    }

    @Test func sameTripDuplicateURLIsRejectedWithoutPersistingADuplicate() throws {
        let repositories = makeRepositories()
        let trip = TestFixtures.trip()
        let useCase = CaptureSharedPlaceUseCase(
            tripRepository: repositories.tripRepository,
            savedPlaceRepository: repositories.savedPlaceRepository
        )
        let url = try #require(URL(string: "https://www.teamlab.art/"))

        try repositories.tripRepository.saveTrip(trip)
        _ = try useCase.execute(
            tripID: trip.id,
            name: "TeamLab Borderless",
            url: url,
            dateSaved: TestDates.december10
        )

        #expect(throws: CaptureSharedPlaceError.placeAlreadySaved) {
            try useCase.execute(
                tripID: trip.id,
                name: "TeamLab Again",
                url: url,
                dateSaved: TestDates.december10
            )
        }

        let places = try repositories.savedPlaceRepository.fetchSavedPlaces(for: trip.id)
        #expect(places.count == 1)
        #expect(places.first?.url == url)
    }

    @Test func sameURLCanBeSavedToDifferentTrips() throws {
        let repositories = makeRepositories()
        let tripA = TestFixtures.trip(name: "Tokyo Trip", destination: "Tokyo")
        let tripB = TestFixtures.trip(name: "Osaka Trip", destination: "Osaka")
        let useCase = CaptureSharedPlaceUseCase(
            tripRepository: repositories.tripRepository,
            savedPlaceRepository: repositories.savedPlaceRepository
        )
        let url = try #require(URL(string: "https://www.teamlab.art/"))

        try repositories.tripRepository.saveTrip(tripA)
        try repositories.tripRepository.saveTrip(tripB)
        _ = try useCase.execute(tripID: tripA.id, name: "TeamLab", url: url)
        _ = try useCase.execute(tripID: tripB.id, name: "TeamLab", url: url)

        #expect(try repositories.savedPlaceRepository.fetchSavedPlaces(for: tripA.id).count == 1)
        #expect(try repositories.savedPlaceRepository.fetchSavedPlaces(for: tripB.id).count == 1)
    }

    @Test func schedulingPersistsStatusAndTripScopedItineraryItems() throws {
        let repositories = makeRepositories()
        let tripA = TestFixtures.trip(name: "Tokyo Trip", destination: "Tokyo")
        let tripB = TestFixtures.trip(name: "Kyoto Trip", destination: "Kyoto")
        let placeA = TestFixtures.savedPlace(tripID: tripA.id, name: "TeamLab")
        let placeB = TestFixtures.savedPlace(tripID: tripB.id, name: "Fushimi Inari")
        let useCase = ScheduleSavedPlaceUseCase(
            tripRepository: repositories.tripRepository,
            savedPlaceRepository: repositories.savedPlaceRepository,
            itineraryRepository: repositories.itineraryRepository,
            calendar: TestDates.calendar
        )

        try repositories.tripRepository.saveTrip(tripA)
        try repositories.tripRepository.saveTrip(tripB)
        try repositories.savedPlaceRepository.saveSavedPlace(placeA)
        try repositories.savedPlaceRepository.saveSavedPlace(placeB)

        let itemA = try useCase.execute(
            savedPlaceID: placeA.id,
            tripID: tripA.id,
            scheduledDate: TestDates.december12,
            startTime: TestDates.december12At10,
            category: .activity
        )
        let itemB = try useCase.execute(
            savedPlaceID: placeB.id,
            tripID: tripB.id,
            scheduledDate: TestDates.december12,
            startTime: TestDates.december12At10,
            category: .activity
        )

        let updatedPlaceA = try #require(try repositories.savedPlaceRepository.fetchSavedPlace(id: placeA.id))
        let updatedPlaceB = try #require(try repositories.savedPlaceRepository.fetchSavedPlace(id: placeB.id))
        let tripAItems = try repositories.itineraryRepository.fetchItineraryItems(for: tripA.id)
        let tripBItems = try repositories.itineraryRepository.fetchItineraryItems(for: tripB.id)

        #expect(updatedPlaceA.status == .scheduled)
        #expect(updatedPlaceB.status == .scheduled)
        #expect(tripAItems.map(\.id) == [itemA.id])
        #expect(tripBItems.map(\.id) == [itemB.id])
    }

    @Test func schedulingOutsideTripDatesDoesNotPersistAnItineraryItemOrStatusChange() throws {
        let repositories = makeRepositories()
        let trip = TestFixtures.trip()
        let place = TestFixtures.savedPlace(tripID: trip.id)
        let useCase = ScheduleSavedPlaceUseCase(
            tripRepository: repositories.tripRepository,
            savedPlaceRepository: repositories.savedPlaceRepository,
            itineraryRepository: repositories.itineraryRepository,
            calendar: TestDates.calendar
        )

        try repositories.tripRepository.saveTrip(trip)
        try repositories.savedPlaceRepository.saveSavedPlace(place)

        #expect(throws: ScheduleSavedPlaceError.outsideTripDates) {
            try useCase.execute(
                savedPlaceID: place.id,
                tripID: trip.id,
                scheduledDate: TestDates.december16,
                startTime: TestDates.december16At10
            )
        }

        let fetchedPlace = try #require(try repositories.savedPlaceRepository.fetchSavedPlace(id: place.id))
        let itineraryItems = try repositories.itineraryRepository.fetchItineraryItems(for: trip.id)

        #expect(fetchedPlace.status == .idea)
        #expect(itineraryItems.isEmpty)
    }

    @Test func deletingTripCascadesSavedPlacesAndItineraryItems() throws {
        let repositories = makeRepositories()
        let trip = TestFixtures.trip()
        let place = TestFixtures.savedPlace(tripID: trip.id)
        let item = ItineraryItem(
            tripID: trip.id,
            sourceSavedPlaceID: place.id,
            title: place.name,
            location: place.name,
            date: TestDates.december12,
            startTime: TestDates.december12At10,
            category: .activity
        )

        try repositories.tripRepository.saveTrip(trip)
        try repositories.savedPlaceRepository.saveSavedPlace(place)
        try repositories.itineraryRepository.saveItineraryItem(item)
        try repositories.tripRepository.deleteTrip(id: trip.id)

        #expect(try repositories.savedPlaceRepository.fetchSavedPlaces(for: trip.id).isEmpty)
        #expect(try repositories.itineraryRepository.fetchItineraryItems(for: trip.id).isEmpty)
        #expect(try count(SavedPlaceEntity.self, in: repositories.context) == 0)
        #expect(try count(ItineraryItemEntity.self, in: repositories.context) == 0)
    }

    private func makeRepositories() -> RepositoryBundle {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        return RepositoryBundle(
            context: context,
            tripRepository: CoreDataTripRepository(context: context),
            savedPlaceRepository: CoreDataSavedPlaceRepository(context: context),
            itineraryRepository: CoreDataItineraryRepository(context: context)
        )
    }

    private func count<T: NSManagedObject>(
        _ type: T.Type,
        in context: NSManagedObjectContext
    ) throws -> Int {
        let request = T.fetchRequest()
        return try context.count(for: request)
    }
}

private struct RepositoryBundle {
    let context: NSManagedObjectContext
    let tripRepository: CoreDataTripRepository
    let savedPlaceRepository: CoreDataSavedPlaceRepository
    let itineraryRepository: CoreDataItineraryRepository
}
