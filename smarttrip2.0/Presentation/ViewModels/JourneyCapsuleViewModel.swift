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

    @ObservationIgnored private let memoryRepository: any MemoryRepository
    @ObservationIgnored private let captureJourneyMemoryUseCase: CaptureJourneyMemoryUseCase

    init(
        tripID: UUID,
        memoryRepository: any MemoryRepository,
        captureJourneyMemoryUseCase: CaptureJourneyMemoryUseCase
    ) {
        self.tripID = tripID
        self.memoryRepository = memoryRepository
        self.captureJourneyMemoryUseCase = captureJourneyMemoryUseCase
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
}
