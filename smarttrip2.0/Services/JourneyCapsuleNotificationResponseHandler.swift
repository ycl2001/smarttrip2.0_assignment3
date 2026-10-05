import Foundation
import UserNotifications

struct JourneyCapsuleNotificationResponseHandler {
    func journeyCapsuleTripID(
        from content: UNNotificationContent
    ) -> UUID? {
        guard content.categoryIdentifier == JourneyCapsuleNotificationContract.categoryIdentifier,
              let payload = JourneyCapsuleNotificationPayload(userInfo: content.userInfo) else {
            return nil
        }

        return payload.tripID
    }
}
