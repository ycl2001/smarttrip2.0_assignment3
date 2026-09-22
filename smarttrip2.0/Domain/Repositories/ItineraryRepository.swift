import Foundation

protocol ItineraryRepository {
    func fetchItineraryItems(
        for tripID: UUID
    ) throws -> [ItineraryItem]

    func saveItineraryItem(
        _ item: ItineraryItem
    ) throws

    func updateItineraryItem(
        _ item: ItineraryItem
    ) throws

    func deleteItineraryItem(
        id: UUID
    ) throws

    func fetchUpcomingItems(
        for tripID: UUID,
        from date: Date
    ) throws -> [ItineraryItem]
}
