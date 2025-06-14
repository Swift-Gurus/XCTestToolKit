import Testing

public typealias AsyncClosure<T: Sendable> = (T) async -> Void

/// A runner that performs a stress test by executing an asynchronous operation repeatedly
/// with controlled randomized sleep strategies between iterations.
///
/// `AsyncStressTestRunner` is designed for validating concurrency, race conditions,
/// and load handling in asynchronous workflows by executing multiple iterations
/// under varying timing patterns.
///
/// - Important:
/// This runner uses `AsyncConfirmationTestRunner` internally to ensure that all
/// expected confirmations occur within a configurable timeout.
///
/// Different randomization strategies can be used to simulate different stress patterns,
/// such as jitter, bursts, or no delay.
@available(macOS 13.0, *)
public struct AsyncStressTestRunner {
    let iterations: Int
    let randomStrategy: RandomStrategy
    let timeout: Duration
    let before: AsyncClosure<Confirmable>?
    let autoConfirm: Bool
    let name: String

    /// Initializes a new `AsyncStressTestRunner`.
    ///
    /// - Parameters:
    ///   - name: A descriptive name for the stress test.
    ///   - iterations: The number of iterations to perform.
    ///   - randomStrategy: The strategy used to randomize sleep intervals between iterations.
    ///   - timeout: The maximum time allowed for all confirmations to complete.
    ///   - autoConfirm: Whether to automatically call `confirm()` after each operation.
    ///   - before: An optional setup closure called before running iterations.
    ///
    /// - autoConfirm:
    ///   Whether each operation should automatically call `confirm()` after execution.
    ///   Defaults to `true`.
    ///
    ///   ### Behavior
    ///   - When `autoConfirm` is `true`:
    ///     After each operation completes successfully, the confirmation is automatically fulfilled.
    ///     This is appropriate for simple workflows where the operation’s completion aligns signals success.
    ///
    ///   - When `autoConfirm` is `false`:
    ///     It is the responsibility of the `operation` closure or an injected object to explicitly call `confirm()`.
    ///     This is useful when the confirmation is triggered asynchronously outside the operation’s immediate scope.
    ///
    ///   ### Example:
    ///   ```swift
    ///   final class Object1 {
    ///       var confirmation: () -> Void = {}
    ///   }
    ///
    ///   final class Root {
    ///       var object1: Object1 = .init()
    ///
    ///       func run() async throws {
    ///           Task {
    ///               try await Task.sleep(for: .seconds(1))
    ///               object1.confirmation()
    ///           }
    ///       }
    ///   }
    ///
    ///   try await asyncStress(autoConfirm: false) { idx, confirmation in
    ///       let root = Root()
    ///       root.object1.confirmation = { confirmation.confirm() }
    ///       try await root.run()
    ///   }
    ///   ```
    ///
    /// - Note:
    /// If `autoConfirm` is disabled, forgetting to manually confirm will cause timeout failures.
    public init(
        name: String,
        iterations: Int,
        randomStrategy: RandomStrategy,
        timeout: Duration,
        autoConfirm: Bool,
        before: AsyncClosure<Confirmable>?
    ) {
        self.iterations = iterations
        self.randomStrategy = randomStrategy
        self.timeout = timeout
        self.autoConfirm = autoConfirm
        self.before = before
        self.name = name
    }

    func perform<R>(operation: @escaping @Sendable (Confirmable) async throws -> R) async throws -> [R] {
        try await asyncConfirmation(expectedCount: iterations, timeout: timeout) { confirmation in
            await before?(confirmation)
            return try await stressRunAsync(count: iterations, strategy: randomStrategy) {
                let value = try await operation(confirmation)
                if autoConfirm {
                    confirmation.confirm()
                }
                return value
            }
        }

    }

}
//
///// A convenient function for performing a stress test over an asynchronous operation.
/////
///// `asyncStress` simplifies launching many iterations of an operation, optionally randomizing
///// execution timing and automatically confirming completions.
/////
///// - Parameters:
/////   - name: A descriptive name for the stress test. Defaults to `"Stress Test"`.
/////   - iterations: The number of iterations to perform. Defaults to 1,000.
/////   - randomStrategy: The strategy for randomizing sleep intervals between operations. Defaults to `.jitter(duration: .microseconds(1))`.
/////   - timeout: The maximum duration allowed for the stress test. Defaults to 20 seconds.
/////   - autoConfirm: Whether each operation should automatically call `confirm()`. Defaults to `true`.
/////   - filePath: The file path of the caller (auto-injected).
/////   - fileId: The file identifier of the caller (auto-injected).
/////   - line: The line number of the caller (auto-injected).
/////   - column: The column number of the caller (auto-injected).
/////   - before: An optional setup closure executed before running iterations, receiving a `Confirmable`.
/////   - operation: The asynchronous operation to perform. Receives the iteration index and a `Confirmable`.
/////
///// - Throws: Rethrows any errors thrown during operations or confirmation waiting.
/////
///// **Important:**
///// Careful use of `autoConfirm` allows flexibility between simple automatic confirmation and
///// complex manual confirmation workflows where confirmation may happen asynchronously
///// via injected objects.
/////
@available(macOS 13.0, *)
@discardableResult
public func asyncStress<R>(
    name: String = "Stress Test",
    iterations: Int = 1_000,
    randomStrategy: RandomStrategy = .jitter(duration: .microseconds(1)),
    timeout: Duration = .seconds(1),
    autoConfirm: Bool = true,
    before: AsyncClosure<Confirmable>? = nil,
    operation: @escaping @Sendable (Confirmable) async throws -> R
) async throws -> [R] {
        try await AsyncStressTestRunner(
            name: name,
            iterations: iterations,
            randomStrategy: randomStrategy,
            timeout: timeout,
            autoConfirm: autoConfirm,
            before: before
        ).perform(operation: operation)
}
