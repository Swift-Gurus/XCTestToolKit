import Testing
import XCTestToolKit
import Foundation
import Numerics

@Suite(.timeLimit(.minutes(1)))
struct AsyncStressTest {

    @Test("executes the correct number of tests")
    func testCount() async throws {
        let iterations = 1_000
        actor TestCounter {
            var testIndicesSeen: [Int] = []
            var currentCount = -1
            func increment() {
                currentCount += 1
                testIndicesSeen.append(currentCount)
            }
        }

        let counter = TestCounter()

        try await asyncStress(iterations: iterations) {_ in
            await counter.increment()
        }

        #expect(await counter.testIndicesSeen.sorted() == Array(0..<iterations))
    }

    @Test("Waits randomly up to the max sleeping interval before starting an operation")
    func maxSleepingInterval() async throws {
        let start = Date()
        let milliseconds: Int64 = 100
        try await asyncStress(randomStrategy: .jitter(duration: .milliseconds(milliseconds)), autoConfirm: true) { _ in
            let now = Date()
            #expect((now.timeIntervalSince(start)) < (Double(milliseconds) / 1_000 * 2)) // Time to arrange the test + buffer time.

        }
    }

    @Test("Waits no more than Timeout duration before ending & marking the test as a failure")
    func duration() async throws {
        let milliseconds: Int64 = 1
        let start = Date()
        await withKnownIssue {
            await #expect(throws: Error.self) {
                try await asyncConfirmation(timeout: .milliseconds(milliseconds)) { confirmation in
                   Task {
                       try await Task.sleep(for: .seconds(5))
                       confirmation.confirm()
                   }

               }
            }
        }

        let end = Date()

        #expect(end.timeIntervalSince(start) < 3)
    }

    @Test("Waits no more than Timeout duration before ending & marking the test as a success")
    func exits_test_before_timeout_when_condition_met() async throws {
        let start = Date()

        let value = try await asyncConfirmation(timeout: .seconds(5)) { confirmation in
            Task {
                try await Task.sleep(for: .seconds(1))
                confirmation.confirm()
            }

           return "test"
        }

        let end = Date()

        #expect(end.timeIntervalSince(start) < 3)
        #expect(value == "test")
    }

    @Test("Waits timeout if confirmation is inverted")
    func waits_timeout_if_confirmation_inverted() async throws {
        let start = Date()

        let value = try await asyncConfirmation(expectedCount: 0, timeout: .seconds(1)) { _ in
            Task {
                try await Task.sleep(for: .seconds(10))
            }

           return "test"
        }

        let end = Date()

        #expect(end.timeIntervalSince(start).isApproximatelyEqual(to: 1, relativeTolerance: 0.1))
        #expect(value == "test")
    }

    @Test("Record an issue if confirmation is overfilled")
    func record_an_issue_confirmation_overfilled() async throws {
        let start = Date()

        await withKnownIssue {
            try await asyncConfirmation(expectedCount: 0, timeout: .seconds(1)) { confirmation in
                Task {
                    confirmation.confirm()

                    try await Task.sleep(for: .seconds(1))
                }
            }
            return
        }

        let end = Date()

        #expect(end.timeIntervalSince(start).isApproximatelyEqual(to: 1, relativeTolerance: 0.1))
    }

    @Test
    func throws_error_when_no_calls_made() async throws {
        await withKnownIssue {
            await #expect(throws: Error.self) {
                try await asyncStress(autoConfirm: false) { _ in }
            }
        }

    }
}
