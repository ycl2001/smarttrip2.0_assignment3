import UIKit
import UserNotifications

final class SmartTripNotificationDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private let responseHandler = JourneyCapsuleNotificationResponseHandler()
    private let router = JourneyCapsuleNotificationRouter.shared

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard let tripID = responseHandler.journeyCapsuleTripID(
            from: response.notification.request.content
        ) else {
            return
        }

        await MainActor.run {
            router.routeToJourneyCapsule(tripID: tripID)
        }
    }
}
