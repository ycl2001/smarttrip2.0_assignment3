import Foundation
import Observation

@Observable
final class TripViewModel {
    var trips: [Trip] = []
    var isLoading = false
    var errorMessage: String?
    var recoverySuggestion: String?

    @ObservationIgnored private let createTripUseCase: CreateTripUseCase
    @ObservationIgnored private let tripRepository: any TripRepository

    init(
        createTripUseCase: CreateTripUseCase,
        tripRepository: any TripRepository
    ) {
        self.createTripUseCase = createTripUseCase
        self.tripRepository = tripRepository
    }

    func loadTrips() {
        isLoading = true
        defer { isLoading = false }

        do {
            trips = try tripRepository.fetchTrips()
            clearError()
        } catch {
            present(error)
        }
    }

    @discardableResult
    func createTrip(
        name: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        coverImageName: String? = nil
    ) -> Trip? {
        do {
            let trip = try createTripUseCase.execute(
                name: name,
                destination: destination,
                startDate: startDate,
                endDate: endDate,
                coverImageName: coverImageName
            )
            loadTrips()
            return trip
        } catch {
            present(error)
            return nil
        }
    }

    func deleteTrip(
        id: UUID
    ) {
        do {
            try tripRepository.deleteTrip(id: id)
            loadTrips()
        } catch {
            present(error)
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
