import Foundation

@available(macOS 13.0, *)
struct AsyncConfirmationsWaiter {
    let duration: Duration
    let pollingInterval: Duration = .microseconds(100)
    let confirmations: [AsyncConfirmation]

    func wait() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await Task.sleep(for: self.duration)
                if confirmations.containsNoInverted {
                    try throwTimeoutError()
                }
                return
            }

            if confirmations.containsNoInverted {
                group.addTask {
                    try await self.poll()
                }
            }

            try await group.nextOrCancelAllOnError()
        }
    }

    func throwTimeoutError() throws {
        let firstUncompleted = self.confirmations.firstUncompleted
        throw Timeout(confirmationName: firstUncompleted?.name ?? "Unknown",
                      expectedCount: firstUncompleted?.expectedCount ?? 0,
                      actualCount: firstUncompleted?.actualCount.rawValue ?? 0)
    }

    func poll() async throws {
        repeat {
            if confirmations.completed || Task.isCancelled {
                return
            }
        } while true
    }
}

private extension Sequence where Element == AsyncConfirmation {
    var completed: Bool {
        allSatisfy(\.completed)
    }

    var firstUncompleted: Element? {
        first(where: { !$0.completed })
    }

    var containsNoInverted: Bool {
        allSatisfy { $0.expectedCount > 0}
    }
}

@available(macOS 13.0, *)
extension AsyncConfirmationsWaiter {
    struct Timeout: Error, LocalizedError {
        let confirmationName: String
        let expectedCount: Int
        let actualCount: Int

        var errorDescription: String? {
            "Timeout waiting for confirmation: \(confirmationName). Expected count: \(expectedCount), actual count: \(actualCount)"
        }
    }
}

@available(macOS 13.0, *)
public func waitForAsyncConfirmations(_ confirmations: [AsyncConfirmation], duration: Duration) async throws {
    try await AsyncConfirmationsWaiter(duration: duration, confirmations: confirmations).wait()
}
