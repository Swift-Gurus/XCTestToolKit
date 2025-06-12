import Foundation

extension ThrowingTaskGroup {
    mutating func nextOrCancelAllOnError(isolation: isolated (any Actor)? = #isolation) async throws -> ChildTaskResult? {
        do {
            defer { cancelAll() }
            return try await self.next(isolation: isolation)
        } catch {
            self.cancelAll()
            throw error
        }
    }
}
