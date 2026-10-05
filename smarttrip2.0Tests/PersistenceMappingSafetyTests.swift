import CoreData
import Foundation
import Testing
@testable import smarttrip2_0

struct PersistenceMappingSafetyTests {
    @Test func savedPlaceWithoutTripRelationshipDoesNotMapToDomain() throws {
        let context = PersistenceController(inMemory: true).container.viewContext
        let entity = SavedPlaceEntity(context: context)
        entity.setValue(UUID(), forKey: "id")
        entity.setValue("TeamLab Planets", forKey: "name")
        entity.setValue(SavedPlaceStatus.idea.rawValue, forKey: "statusRawValue")
        entity.setValue(TestDates.december10, forKey: "dateSaved")

        do {
            _ = try SavedPlaceMapper.toDomain(entity)
            Issue.record("Expected missing Trip relationship mapping failure.")
        } catch PersistenceMappingError.missingTripRelationship(let entityName) {
            #expect(entityName == "SavedPlaceEntity")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func itineraryItemWithoutTripRelationshipDoesNotMapToDomain() throws {
        let context = PersistenceController(inMemory: true).container.viewContext
        let entity = ItineraryItemEntity(context: context)
        entity.setValue(UUID(), forKey: "id")
        entity.setValue("Tsukiji Market", forKey: "title")
        entity.setValue("Tsukiji Market", forKey: "location")
        entity.setValue(TestDates.december12, forKey: "date")
        entity.setValue(TestDates.december12At10, forKey: "startTime")
        entity.setValue(ItineraryCategory.food.rawValue, forKey: "categoryRawValue")

        do {
            _ = try ItineraryItemMapper.toDomain(entity)
            Issue.record("Expected missing Trip relationship mapping failure.")
        } catch PersistenceMappingError.missingTripRelationship(let entityName) {
            #expect(entityName == "ItineraryItemEntity")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
