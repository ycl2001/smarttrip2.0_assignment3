import Foundation
@testable import smarttrip2_0

final class MockMemoryRepository: MemoryRepository {
    var memories: [TripMemory]
    var errorToThrow: Error?
    var saveCallCount = 0
    var deleteCallCount = 0
    var lastSavedMemory: TripMemory?
    var lastDeletedMemoryID: UUID?

    init(memories: [TripMemory] = []) {
        self.memories = memories
    }

    func fetchMemories(
        for tripID: UUID
    ) throws -> [TripMemory] {
        if let errorToThrow {
            throw errorToThrow
        }

        return memories
            .filter { $0.tripID == tripID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func saveMemory(
        _ memory: TripMemory
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        saveCallCount += 1
        lastSavedMemory = memory
        memories.append(memory)
    }

    func deleteMemory(
        id: UUID
    ) throws {
        if let errorToThrow {
            throw errorToThrow
        }

        deleteCallCount += 1
        lastDeletedMemoryID = id
        memories.removeAll { $0.id == id }
    }
}
