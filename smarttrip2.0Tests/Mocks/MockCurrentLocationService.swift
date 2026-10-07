import CoreLocation
@testable import smarttrip2_0

@MainActor
final class MockCurrentLocationService: CurrentLocationProviding {
    var authorizationStatus: CLAuthorizationStatus
    var location: CLLocation?
    var placeName: String?
    var locationError: Error?
    var placeError: Error?
    var authorizationStatusAfterRequest: CLAuthorizationStatus?
    private(set) var authorizationRequestCount = 0

    init(authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse) {
        self.authorizationStatus = authorizationStatus
    }

    func requestWhenInUseAuthorization() async {
        authorizationRequestCount += 1
        if let authorizationStatusAfterRequest {
            authorizationStatus = authorizationStatusAfterRequest
        }
    }

    func currentLocation() async throws -> CLLocation {
        if let locationError { throw locationError }
        guard let location else { throw CurrentLocationError.locationUnavailable }
        return location
    }

    func readablePlace(for location: CLLocation) async throws -> String {
        if let placeError { throw placeError }
        guard let placeName else { throw CurrentLocationError.placeUnavailable }
        return placeName
    }
}
