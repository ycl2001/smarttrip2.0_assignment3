import CoreLocation
import Foundation

@MainActor
protocol CurrentLocationProviding: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }

    func requestWhenInUseAuthorization() async
    func currentLocation() async throws -> CLLocation
    func readablePlace(for location: CLLocation) async throws -> String
}

enum CurrentLocationError: Error {
    case authorizationDenied
    case authorizationRestricted
    case locationUnavailable
    case placeUnavailable
}

@MainActor
final class CurrentLocationService: NSObject, CurrentLocationProviding {
    private let locationManager: CLLocationManager
    private var authorizationContinuation: CheckedContinuation<Void, Never>?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self
    }

    func requestWhenInUseAuthorization() async {
        guard authorizationStatus == .notDetermined else {
            return
        }

        await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func currentLocation() async throws -> CLLocation {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            break
        case .denied:
            throw CurrentLocationError.authorizationDenied
        case .restricted:
            throw CurrentLocationError.authorizationRestricted
        case .notDetermined:
            throw CurrentLocationError.authorizationDenied
        @unknown default:
            throw CurrentLocationError.locationUnavailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    func readablePlace(for location: CLLocation) async throws -> String {
        let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            throw CurrentLocationError.placeUnavailable
        }

        let components = [
            placemark.name,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .reduce(into: [String]()) { result, value in
            if !result.contains(value) {
                result.append(value)
            }
        }

        guard !components.isEmpty else {
            throw CurrentLocationError.placeUnavailable
        }

        return components.prefix(3).joined(separator: ", ")
    }
}

extension CurrentLocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else {
            return
        }

        authorizationContinuation?.resume()
        authorizationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            locationContinuation?.resume(throwing: CurrentLocationError.locationUnavailable)
            locationContinuation = nil
            return
        }

        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: CurrentLocationError.locationUnavailable)
        locationContinuation = nil
    }
}
