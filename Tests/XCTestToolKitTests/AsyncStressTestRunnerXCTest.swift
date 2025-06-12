import XCTest
@testable import XCTestToolKit

final class AsyncStressTestRunnerXCTest: XCTestCase {
    func test_waits_for_confirmations_and_report_success() async throws {
        let rootObject = RootObjectFake()
        
        try await asyncStress(
            timeout: .seconds(2),
            autoConfirm: false
        ) { confirmation in
            rootObject.dependant.confirmation = { confirmation.confirm() }
        } operation: { _ in
            try await rootObject.run()
        }
    }
    
    func test_fails_when_timeout_is_reached() async throws {
        let rootObject = RootObjectFake()
        await XCTAssertThrows {
            try await asyncStress(
                timeout: .seconds(2),
                autoConfirm: false) { _ in
                try await rootObject.run()
            }
        }
    }
    
    func test_fulfillment_throws_on_timeout() async throws {
        let confirmation = AsyncConfirmation(expectedCount: 1, name: "Test")
        let waiter = AsyncConfirmationsWaiter(duration: .seconds(1), confirmations: [confirmation])
        await XCTAssertThrows {
            try await waiter.wait()
        }
    }
}

func XCTAssertThrows<T>(
    _ file: StaticString = #file,
    line: UInt = #line,
    expression: () async throws -> T
) async {
    do {
        _ = try await expression()
        XCTFail("Expect throw, but didn't throw in \(file):\(line)")
    } catch {
        return
    }
}
