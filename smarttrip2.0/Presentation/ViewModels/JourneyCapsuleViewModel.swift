import Foundation
import Observation

@Observable
final class JourneyCapsuleViewModel {
    let tripID: UUID
    var memories: [TripMemory] = []
    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    var recoverySuggestion: String?
    var reminderMessage: String?
    var isSchedulingReminder = false

    @ObservationIgnored private let memoryRepository: any MemoryRepository
    @ObservationIgnored private let captureJourneyMemoryUseCase: CaptureJourneyMemoryUseCase
    @ObservationIgnored private let notificationAuthorizer: any JourneyCapsuleNotificationAuthorizing
    @ObservationIgnored private let notificationScheduler: any JourneyCapsuleNotificationScheduling
    @ObservationIgnored private let placeAutocomplete: any PlaceAutocompleteProviding
    @ObservationIgnored private let currentLocation: any CurrentLocationProviding
    @ObservationIgnored private let now: () -> Date

    init(
        tripID: UUID,
        memoryRepository: any MemoryRepository,
        captureJourneyMemoryUseCase: CaptureJourneyMemoryUseCase,
        notificationAuthorizer: any JourneyCapsuleNotificationAuthorizing,
        notificationScheduler: any JourneyCapsuleNotificationScheduling,
        placeAutocomplete: any PlaceAutocompleteProviding,
        currentLocation: any CurrentLocationProviding,
        now: @escaping () -> Date = Date.init
    ) {
        self.tripID = tripID
        self.memoryRepository = memoryRepository
        self.captureJourneyMemoryUseCase = captureJourneyMemoryUseCase
        self.notificationAuthorizer = notificationAuthorizer
        self.notificationScheduler = notificationScheduler
        self.placeAutocomplete = placeAutocomplete
        self.currentLocation = currentLocation
        self.now = now
    }

    func loadMemories() {
        isLoading = true
        defer {
            isLoading = false
        }

        do {
            memories = try memoryRepository.fetchMemories(for: tripID)
            clearError()
        } catch {
            present(error)
        }
    }

    @discardableResult
    func captureMoment(
        location: String?,
        caption: String?,
        capturedAt: Date
    ) -> TripMemory? {
        guard !isSaving else {
            return nil
        }

        isSaving = true
        defer {
            isSaving = false
        }

        do {
            let memory = try captureJourneyMemoryUseCase.execute(
                tripID: tripID,
                location: location,
                caption: caption,
                capturedAt: capturedAt
            )
            memories = try memoryRepository.fetchMemories(for: tripID)
            clearError()
            return memory
        } catch {
            present(error)
            return nil
        }
    }

    func clearPresentationError() {
        clearError()
    }

    func makeCaptureMomentViewModel() -> CaptureMomentViewModel {
        CaptureMomentViewModel(
            captureJourneyMemoryUseCase: captureJourneyMemoryUseCase,
            placeAutocomplete: placeAutocomplete,
            currentLocation: currentLocation
        )
    }

    @discardableResult
    func scheduleReminder(
        for trip: Trip,
        at date: Date
    ) async -> Bool {
        guard !isSchedulingReminder else {
            return false
        }

        guard date > now() else {
            reminderMessage = "Choose a future time for your Journey Capsule reminder."
            return false
        }

        isSchedulingReminder = true
        defer {
            isSchedulingReminder = false
        }

        do {
            guard try await notificationAuthorizer.requestAuthorization() else {
                reminderMessage = "Notifications are turned off. Enable them in Settings to receive Journey Capsule reminders."
                return false
            }

            let payload = JourneyCapsuleNotificationPayload(
                tripID: trip.id,
                tripName: trip.name,
                destination: trip.destination,
                tripDay: tripDay(for: date, in: trip)
            )
            _ = try await notificationScheduler.scheduleReminder(
                payload: payload,
                at: date
            )
            reminderMessage = "Journey Capsule reminder set."
            return true
        } catch {
            reminderMessage = "We couldn't set your Journey Capsule reminder. Try again."
            return false
        }
    }

    func clearReminderMessage() {
        reminderMessage = nil
    }

    private func clearError() {
        errorMessage = nil
        recoverySuggestion = nil
    }

    private func present(
        _ error: Error
    ) {
        let localizedError = error as? any LocalizedError
        errorMessage = localizedError?.errorDescription ?? error.localizedDescription
        recoverySuggestion = localizedError?.recoverySuggestion
    }

    private func tripDay(
        for date: Date,
        in trip: Trip
    ) -> Int? {
        let calendar = Calendar.current
        let tripStart = calendar.startOfDay(for: trip.startDate)
        let tripEnd = calendar.startOfDay(for: trip.endDate)
        let reminderDay = calendar.startOfDay(for: date)

        guard reminderDay >= tripStart, reminderDay <= tripEnd else {
            return nil
        }

        return (calendar.dateComponents([.day], from: tripStart, to: reminderDay).day ?? 0) + 1
    }
}
