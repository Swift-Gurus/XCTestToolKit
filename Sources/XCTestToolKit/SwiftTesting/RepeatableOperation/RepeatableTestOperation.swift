import Foundation
public typealias RepeatingOperation<R> = () async throws -> sending R
public typealias AsyncThrowableClosure<T: Sendable> = @Sendable (T) async throws -> Void

/// A utility for repeatedly running asynchronous operations with random delays between executions.
///
/// `RepeatOperationRunner` is designed for stress testing and concurrency testing in Swift, QuickSpec, or XCTestCase environments.
/// It launches multiple operations concurrently, with each operation starting after a random sleep interval.
@available(macOS 13.0, *)
struct RepeatOperationRunner<R> {
    let count: Int
    let randomStrategy: RandomStrategy
    
    /// Initializes a new `RepeatOperationRunner`.
    ///
    /// - Parameters:
    ///   - count: The number of times the operation will be repeated.
    ///   - maxSleepInterval: The maximum random delay before each operation starts.
    ///   - operation: The asynchronous, throwable operation to perform, accepting the operation index as input.
    init(
        count: Int,
        randomStrategy: RandomStrategy
    ) {
        self.count = count
        self.randomStrategy = randomStrategy
    }
    
    func perform(_ operation: @escaping RepeatingOperation<R>) async throws -> [R] {
        try await withThrowingTaskGroup(of: R.self) { taskGroup in
            for _ in 0..<count {
                taskGroup.addTask {
                    let sleepDuration = randomDuration(for: randomStrategy)
                    try await sleepAsync(sleepDuration)
                    return try await operation()
                }
            }
            
            var results: [R] = []
            for try await result in taskGroup {
                results.append(result)
            }
        
            return results
        }
    }
}

/// A strategy that defines how random sleep intervals should be generated during stress testing.
@available(macOS 13.0, *)
public enum RandomStrategy {
    /// No sleep at all between operations (pure maximum stress).
    case none
    
    /// Uniform random sleep between 0 and `maxSleepInterval`.
    case jitter(duration: Duration)
}

@available(macOS 13.0, *)
private func sleepAsync(_ duration: Duration) async throws {
    guard duration > .zero else { return }
    try await Task.sleep(for: duration)
}

@available(macOS 13.0, *)
private func randomDuration(for strategy: RandomStrategy) -> Duration {
    switch strategy {
    case .none:
        return .zero
        
    case .jitter(let duration):
        return createRandomDuration(upTo: duration)
    }

}

@available(macOS 13.0, *)
private func createRandomDuration(upTo duration: Duration) -> Duration {
    Duration(
        secondsComponent: Int64.random(in: 0...duration.components.seconds),
        attosecondsComponent: Int64.random(in: 0...duration.components.attoseconds)
    )
}

@available(macOS 13.0, *)
public func stressRunAsync<R>(count: Int = 1000,
                              strategy: RandomStrategy = .jitter(duration: .microseconds(200)),
                              _ operation: @escaping RepeatingOperation<R>) async throws -> [R] {
    try await RepeatOperationRunner(count: count, randomStrategy: strategy).perform(operation)
}
