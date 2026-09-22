import Foundation

enum PersistenceMappingError: Error {
    case missingRequiredField(
        entity: String,
        field: String
    )

    case invalidSavedPlaceStatus(
        String
    )

    case invalidItineraryCategory(
        String
    )

    case invalidURL(
        String
    )

    case missingTripRelationship(
        entity: String
    )
}
