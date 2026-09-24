import Foundation
@testable import smarttrip2_0

final class MockItineraryRepository: ItineraryRepository {
    var itineraryItems: [ItineraryItem]
    var errorToThrow: Error?
    var saveCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0
    var lastSavedItem: ItineraryItem?
    var lastUpdatedItem: ItineraryItem?
    var lastDeletedItemID: UUID?

    init(itineraryItems: [ItineraryItem] = []) {
        self.itineraryItems = itineraryItems
    }

    func fetchItineraryItems(
        for tripID: UUID
    ) throws -> [ItineraryItem] {
        if let errorToThrow {
            throw errorToThrow
        }

        return itineraryItems
            .filter { $0.tripID == tripID }
            .sorted(by: isEarlier)
    }

    func saveItineraryItem(
        _ item: ItineraryItem
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        saveCallCount += 1
        lastSavedItem = item
        itineraryItems.append(item)
    }

    func updateItineraryItem(
        _ item: ItineraryItem
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        updateCallCount += 1
        lastUpdatedItem = item

        if let index = itineraryItems.firstIndex(where: { $0.id == item.id }) {
            itineraryItems[index] = item
        } else {
            itineraryItems.append(item)
        }
    }

    func deleteItineraryItem(
        id: UUID
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        deleteCallCount += 1
        lastDeletedItemID = id
        itineraryItems.removeAll { $0.id == id }
    }

    func fetchUpcomingItems(
        for tripID: UUID,
        from date: Date
    ) throws -> [ItineraryItem] {
        if let errorToThrow {
            throw errorToThrow
        }

        return itineraryItems
            .filter { item in
                item.tripID == tripID && (item.startTime ?? item.date) >= date
            }
            .sorted(by: isEarlier)
    }

    private func isEarlier(
        _ lhs: ItineraryItem,
        than rhs: ItineraryItem
    ) -> Bool {
        if lhs.date != rhs.date {
            return lhs.date < rhs.date
        }

        return (lhs.startTime ?? lhs.date) < (rhs.startTime ?? rhs.date)
    }
}
