import Foundation
import Observation

@Observable
final class JourneyCapsuleNotificationRouter {
    static let shared = JourneyCapsuleNotificationRouter()

    private(set) var pendingJourneyCapsuleTripID: UUID?

    private init() {}

    @MainActor
    func routeToJourneyCapsule(
        tripID: UUID
    ) {
        pendingJourneyCapsuleTripID = tripID
    }

    @MainActor
    func consumePendingJourneyCapsuleTripID() -> UUID? {
        defer {
            pendingJourneyCapsuleTripID = nil
        }

        return pendingJourneyCapsuleTripID
    }
}
