import Foundation
import Testing
@testable import smarttrip2_0

@MainActor
struct JourneyCapsuleViewModelTests {
    @Test func journeyCapsuleLoadsMemoriesForSelectedTripOnly() throws {
        let trip = TestFixtures.trip()
        let otherTrip = TestFixtures.trip(name: "Kyoto Trip", destination: "Kyoto")
        let selectedMemory = TestFixtures.memory(tripID: trip.id)
        let otherMemory = TestFixtures.memory(tripID: otherTrip.id)
        let viewModel = makeViewModel(
            trip: trip,
            memories: [selectedMemory, otherMemory]
        )

        viewModel.loadMemories()

        #expect(viewModel.memories.map(\.id) == [selectedMemory.id])
        #expect(viewModel.errorMessage == nil)
    }

    @Test func savingMomentRefreshesDisplayedMemories() throws {
        let trip = TestFixtures.trip()
        let viewModel = makeViewModel(trip: trip)

        let memory = viewModel.captureMoment(
            location: "Shibuya Crossing",
            caption: "A bright walk after dinner.",
            capturedAt: TestDates.december12At18
        )

        let savedMemory = try #require(memory)
        #expect(viewModel.memories.map(\.id) == [savedMemory.id])
        #expect(viewModel.memories.first?.location == "Shibuya Crossing")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func missingLocationIsAllowedWhenCaptionIsPresent() throws {
        let trip = TestFixtures.trip()
        let viewModel = makeViewModel(trip: trip)

        let memory = viewModel.captureMoment(
            location: " ",
            caption: "Quiet train ride back to the hotel.",
            capturedAt: TestDates.december12At18
        )

        let savedMemory = try #require(memory)
        #expect(savedMemory.location == nil)
        #expect(savedMemory.caption == "Quiet train ride back to the hotel.")
    }

    @Test func emptyMemoryShowsDomainErrorAndDoesNotSave() {
        let trip = TestFixtures.trip()
        let viewModel = makeViewModel(trip: trip)

        let memory = viewModel.captureMoment(
            location: " ",
            caption: "   ",
            capturedAt: TestDates.december12At18
        )

        #expect(memory == nil)
        #expect(viewModel.memories.isEmpty)
        #expect(viewModel.errorMessage == CaptureJourneyMemoryError.emptyMemory.errorDescription)
    }

    @Test func failedMemoryFetchShowsHumanReadableError() {
        let trip = TestFixtures.trip()
        let memoryRepository = MockMemoryRepository()
        memoryRepository.errorToThrow = CaptureJourneyMemoryError.tripNotFound
        let viewModel = makeViewModel(
            trip: trip,
            memoryRepository: memoryRepository
        )

        viewModel.loadMemories()

        #expect(viewModel.errorMessage == CaptureJourneyMemoryError.tripNotFound.errorDescription)
        #expect(viewModel.memories.isEmpty)
    }

    @Test func failedSaveKeepsSheetStateAvailableForCorrection() {
        let trip = TestFixtures.trip()
        let memoryRepository = MockMemoryRepository()
        memoryRepository.errorToThrow = CaptureJourneyMemoryError.emptyMemory
        let viewModel = makeViewModel(
            trip: trip,
            memoryRepository: memoryRepository
        )

        let memory = viewModel.captureMoment(
            location: "Tokyo Tower",
            caption: "Evening view.",
            capturedAt: TestDates.december12At18
        )

        #expect(memory == nil)
        #expect(viewModel.isSaving == false)
        #expect(viewModel.errorMessage == CaptureJourneyMemoryError.emptyMemory.errorDescription)
    }

    @Test func grantedPermissionSchedulesTripSpecificReminder() async {
        let trip = TestFixtures.trip()
        let authorizer = MockJourneyCapsuleNotificationAuthorizer(isAuthorized: true)
        let scheduler = MockJourneyCapsuleNotificationScheduler()
        let reminderDate = TestDates.december12At18
        let viewModel = makeViewModel(
            trip: trip,
            notificationAuthorizer: authorizer,
            notificationScheduler: scheduler,
            now: { TestDates.december12At10 }
        )

        let didSchedule = await viewModel.scheduleReminder(for: trip, at: reminderDate)

        #expect(didSchedule)
        #expect(scheduler.payloads == [
            smarttrip2_0.JourneyCapsuleNotificationPayload(
                tripID: trip.id,
                tripName: trip.name,
                destination: trip.destination,
                tripDay: 3
            )
        ])
        #expect(scheduler.dates == [reminderDate])
        #expect(viewModel.reminderMessage == "Journey Capsule reminder set.")
    }

    @Test func deniedPermissionDoesNotScheduleReminder() async {
        let trip = TestFixtures.trip()
        let authorizer = MockJourneyCapsuleNotificationAuthorizer(isAuthorized: false)
        let scheduler = MockJourneyCapsuleNotificationScheduler()
        let viewModel = makeViewModel(
            trip: trip,
            notificationAuthorizer: authorizer,
            notificationScheduler: scheduler,
            now: { TestDates.december12At10 }
        )

        let didSchedule = await viewModel.scheduleReminder(for: trip, at: TestDates.december12At18)

        #expect(!didSchedule)
        #expect(scheduler.payloads.isEmpty)
        #expect(viewModel.reminderMessage == "Notifications are turned off. Enable them in Settings to receive Journey Capsule reminders.")
    }

    @Test func pastReminderDateIsRejectedWithoutRequestingPermission() async {
        let trip = TestFixtures.trip()
        let authorizer = MockJourneyCapsuleNotificationAuthorizer(isAuthorized: true)
        let scheduler = MockJourneyCapsuleNotificationScheduler()
        let viewModel = makeViewModel(
            trip: trip,
            notificationAuthorizer: authorizer,
            notificationScheduler: scheduler,
            now: { TestDates.december12At18 }
        )

        let didSchedule = await viewModel.scheduleReminder(for: trip, at: TestDates.december12At10)

        #expect(!didSchedule)
        #expect(authorizer.requestCount == 0)
        #expect(scheduler.payloads.isEmpty)
        #expect(viewModel.reminderMessage == "Choose a future time for your Journey Capsule reminder.")
    }

    @Test func schedulingFailureShowsHumanReadableFeedback() async {
        let trip = TestFixtures.trip()
        let authorizer = MockJourneyCapsuleNotificationAuthorizer(isAuthorized: true)
        let scheduler = MockJourneyCapsuleNotificationScheduler()
        scheduler.errorToThrow = ReminderTestError.failed
        let viewModel = makeViewModel(
            trip: trip,
            notificationAuthorizer: authorizer,
            notificationScheduler: scheduler,
            now: { TestDates.december12At10 }
        )

        let didSchedule = await viewModel.scheduleReminder(for: trip, at: TestDates.december12At18)

        #expect(!didSchedule)
        #expect(viewModel.reminderMessage == "We couldn't set your Journey Capsule reminder. Try again.")
    }

    private func makeViewModel(
        trip: Trip,
        memories: [TripMemory] = [],
        memoryRepository: MockMemoryRepository? = nil,
        notificationAuthorizer: MockJourneyCapsuleNotificationAuthorizer? = nil,
        notificationScheduler: MockJourneyCapsuleNotificationScheduler? = nil,
        now: @escaping () -> Date = Date.init
    ) -> JourneyCapsuleViewModel {
        let tripRepository = MockTripRepository(trips: [trip])
        let memoryRepository = memoryRepository ?? MockMemoryRepository(memories: memories)
        let notificationAuthorizer = notificationAuthorizer ?? MockJourneyCapsuleNotificationAuthorizer(isAuthorized: true)
        let notificationScheduler = notificationScheduler ?? MockJourneyCapsuleNotificationScheduler()
        let useCase = CaptureJourneyMemoryUseCase(
            tripRepository: tripRepository,
            memoryRepository: memoryRepository
        )

        return JourneyCapsuleViewModel(
            tripID: trip.id,
            memoryRepository: memoryRepository,
            captureJourneyMemoryUseCase: useCase,
            notificationAuthorizer: notificationAuthorizer,
            notificationScheduler: notificationScheduler,
            placeAutocomplete: MockPlaceAutocompleteService(),
            currentLocation: MockCurrentLocationService(),
            now: now
        )
    }
}

private final class MockJourneyCapsuleNotificationAuthorizer: @MainActor JourneyCapsuleNotificationAuthorizing {
    var isAuthorized: Bool
    var errorToThrow: Error?
    private(set) var requestCount = 0

    init(isAuthorized: Bool) {
        self.isAuthorized = isAuthorized
    }

    @discardableResult
    @MainActor
    func requestAuthorization() async throws -> Bool {
        requestCount += 1

        if let errorToThrow {
            throw errorToThrow
        }

        return isAuthorized
    }
}

private final class MockJourneyCapsuleNotificationScheduler: @MainActor JourneyCapsuleNotificationScheduling {
    var errorToThrow: Error?
    private(set) var payloads: [smarttrip2_0.JourneyCapsuleNotificationPayload] = []
    private(set) var dates: [Date] = []

    @discardableResult
    @MainActor
    func scheduleReminder(
        payload: smarttrip2_0.JourneyCapsuleNotificationPayload,
        at date: Date
    ) async throws -> String {
        if let errorToThrow {
            throw errorToThrow
        }

        payloads.append(payload)
        dates.append(date)
        return "test-reminder"
    }
}

private enum ReminderTestError: Error {
    case failed
}
