import Foundation

protocol MemoryRepository {
    func fetchMemories(
        for tripID: UUID
    ) throws -> [TripMemory]

    func saveMemory(
        _ memory: TripMemory
    ) throws

    func deleteMemory(
        id: UUID
    ) throws
}
