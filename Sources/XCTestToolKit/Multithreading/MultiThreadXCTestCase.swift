import XCTest

// swiftlint:disable test_case_accessibility

open class MultiThreadXCTestCase: XCTestCase {
    public var stressTestCount: Int = Constants.defaultStressCount
    public var maxThreadSleepingInterval: UInt32 = Constants.defaultSleepingInterval
    public var defaultWaitingInterval: TimeInterval = 20
    private let concurrentQueue = DispatchQueue(label: "MultiThreadXCTestCase queue", attributes: .concurrent)

    public func stressTestAsync(operation: @escaping (XCTestExpectation, Int) -> Void) {
        performMultithreadStressTest(autofullfill: false, operation: operation)
    }

    public func stressTestSync(operation: @escaping (Int) -> Void) {
        performMultithreadStressTest { _, idx in operation(idx) }
    }

    public func stressTestAsync(autofullfill: Bool = true,
                                operation: @escaping  (XCTestExpectation, Int) async throws -> Void ) async throws {
        let expectation = defaultExpectation(name: "stress.test.expectation")
        expectation.expectedFulfillmentCount = stressTestCount
        try await stressTestAsync(customExpectation: expectation, operation: operation)
    
    }
    
    public func stressTestAsync(autofullfill: Bool = true,
                                customExpectation: XCTestExpectation,
                                operation: @escaping  (XCTestExpectation, Int) async throws -> Void ) async throws {
        let expectation = customExpectation
        for i in 0..<stressTestCount {
            Task {
                let sleepVal = UInt32.random(in: 0...maxThreadSleepingInterval)
                usleep(sleepVal)
                try? await operation(expectation, i)

                if autofullfill { expectation.fulfill() }
            }
        }

        await fulfillment(of: [expectation], timeout: defaultWaitingInterval)
    }

    private func performMultithreadStressTest(autofullfill: Bool = true,
                                              operation: @escaping (XCTestExpectation, Int) -> Void) {
        let expectation = defaultExpectation(name: "multithread stress test")
        expectation.expectedFulfillmentCount = stressTestCount
        for i in 0..<stressTestCount {
            let item = dispatchItem(expectation: autofullfill ? expectation : nil) {
                operation(expectation, i)
            }
            concurrentQueue.async(execute: item)
        }

        wait(for: [expectation], timeout: defaultWaitingInterval)
    }

    private func dispatchItem(expectation: XCTestExpectation?,
                              operation: @escaping () -> Void) -> DispatchWorkItem {
        .init {[maxThreadSleepingInterval] in
            let sleepVal = UInt32.random(in: 0...maxThreadSleepingInterval)
            usleep(sleepVal)
            operation()
            expectation?.fulfill()
        }
    }
}
