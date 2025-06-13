import Testing
import XCTest

public typealias ConfirmationOperation<R> = (Confirmable) async throws -> sending R
/// A runner that performs an asynchronous confirmation-based test.
///
/// `AsyncConfirmationTestRunner` is designed for validating that an asynchronous operation
/// triggers a specific number of confirmations (signals) within a given timeout,
/// suitable for Swift tests, XCTest, QuickSpec
///
/// - Important:
/// Apple's native `confirmation(expectedCount:perform:)` API does not properly await asynchronous operations
/// inside the `perform` closure.
/// As a result, if confirmation depends on awaited work (e.g., delayed task completion), the test may incorrectly fail.
///
/// `AsyncConfirmationTestRunner` ensures the `operation` closure is fully awaited before verifying confirmations,
/// providing better reliability for tests involving asynchronous workflows.
///
/// - Example:
/// ```swift
/// final class Object1 {
///     var confirmation: () -> Void = {}
/// }
///
/// final class Root {
///     var object1: Object1 = .init()
///
///     func run() async throws {
///         Task {
///             try await Task.sleep(for: .seconds(1))
///             object1.confirmation()
///         }
///     }
/// }
///
/// try await asyncConfirmation { confirmation in
///     let root = Root()
///     root.object1.confirmation = { confirmation.confirm() }
///     try await root.run()
/// }
/// ```
///
/// In this example, if using Apple's `confirmation {}` instead of `asyncConfirmation`, the test would still fail.
/// While the native `confirmation` does await the `try await root.run()` call, the `run()` method internally dispatches
/// work onto a separate detached task, which is not awaited. As a result, the test assumes the operation is complete
/// before the confirmation is triggered, causing a premature failure.
///
/// `AsyncConfirmationTestRunner` ensures that confirmations are properly awaited even when the operation internally
/// dispatches asynchronous work.
@available(macOS 13.0, *)
public struct AsyncConfirmationTestRunner<R: Sendable> {
    let expectedCount: Int
    let timeout: Duration
    let name: String

    let sourceLocation: Testing.SourceLocation
    /// Initializes a new `AsyncConfirmationTestRunner`.
    ///
    /// - Parameters:
    ///   - name: A descriptive name for the confirmation context.
    ///   - expectedCount: The number of expected confirmation calls.
    ///   - timeout: The maximum time to wait for confirmations
    public init(
        name: String,
        expectedCount: Int,
        timeout: Duration,
        sourceLocation: Testing.SourceLocation
    ) {
        self.expectedCount = expectedCount
        self.timeout = timeout
        self.name = name
        self.sourceLocation = sourceLocation
    }

    /// Performs the confirmation test.
       ///
       /// - Parameters:
       ///   - location: The source location from which the test was called, used for reporting failures.
       ///   - operation: The asynchronous operation that should trigger the confirmations.
       /// - Throws: Rethrows any errors thrown by the operation, or a timeout error if confirmations are not fulfilled.
    public func perform(operation: @escaping ConfirmationOperation<R>) async throws -> R {
        let confirmation = AsyncConfirmation(expectedCount: expectedCount, name: name)
        let waiter = AsyncConfirmationsWaiter(duration: timeout, confirmations: [confirmation])
        async let result = operation(confirmation)
        try await waiter.wait()
        return try await result
    }
}

@available(macOS 13.0, *)
enum RunnerError: Error {
    case noResultNoConfirmation
    case noResult
    case timeoutWaitingForConfirmation

}

/// A convenient function for writing confirmation-based async tests.
///
/// `asyncConfirmation` simplifies setting up and running confirmation tests where a `Confirmable`
/// object is passed into the operation and used to signal successful completion.
///
/// - Parameters:
///   - expectedCount: The number of expected confirmation calls. Defaults to 1.
///   - name: A descriptive name for the confirmation. Defaults to `"Async Confirmation"`.
///   - timeout: The maximum duration to wait for confirmations. Defaults to 1 second.
///   - operation: The asynchronous operation that should trigger the confirmations.
/// - Throws: Rethrows any errors thrown by the operation, or a timeout error if confirmations are not fulfilled.
/// - Note:
/// This function provides better reliability than Apple's `confirmation {}` when the operation
/// internally dispatches detached asynchronous work that is not directly awaited.
@available(macOS 13.0, *)
@discardableResult
public func asyncConfirmation<R>(
    expectedCount: Int = 1,
    name: String = "",
    timeout: Duration = .seconds(1),
    sourceLocation: Testing.SourceLocation = #_sourceLocation,
    operation: @escaping ConfirmationOperation<R>
) async throws -> R {
    try await AsyncConfirmationTestRunner(
        name: name,
        expectedCount: expectedCount,
        timeout: timeout,
        sourceLocation: sourceLocation
    ).perform(operation: operation)
}
