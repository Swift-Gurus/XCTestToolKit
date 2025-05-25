import Foundation
import XCTest
// swiftlint: disable prefer_nimble

/// Validate if async block throws an error
/// - Parameters:
///   - block: async block
///   - catchBlock: block for error validation
///   - file: File
///   - line: Line
@available(iOS 13.0, *)
public func XCTAssertThrowsErrorAsync(_ block: () async throws -> Void,
                                      catchBlock: ((Error) -> Void)? = nil,
                                      file: StaticString = #filePath,
                                      line: UInt = #line) async {
    do {
        try await block()
        XCTFail("Expect to throw an error but was success", file: file, line: line)
    } catch {
        catchBlock?(error)
    }
}

/// Validate if async block throws an error
/// - Parameters:
///   - block: throwable block
///   - catchBlock: block for error validation
///   - file: File
///   - line: Line
public func XCTAssertThrowsError(_ block: () throws -> Void,
                                 catchBlock: ((Error) -> Void)? = nil,
                                 file: StaticString = #filePath,
                                 line: UInt = #line) {
    do {
        try block()
        XCTFail("Expect to throw an error but was success", file: file, line: line)
    } catch {
        catchBlock?(error)
    }
}

public extension XCTestCase {
    private static let defaultTimmerJitter: Int = 2
    /// Creates default expectation with assertOverFulfill = true
    var defaultExpectation: XCTestExpectation {
        defaultExpectation(name: "\(self)")
    }

    /// Creates default expectation with assertOverFulfill = true and custom name
    func defaultExpectation(name: String) -> XCTestExpectation {
        let exp = XCTestExpectation(description: name)
        exp.assertForOverFulfill = true
        return exp
    }

    /// Convenience method for memory leak validation
    /// - Parameters:
    ///   - obj: Any Object
    ///   - file: file
    ///   - line: line
    func expectNoMemoryLeak(obj: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock {[weak obj] in
            XCTAssertNil(obj,
                         "the object \(String(describing: obj)) was not deallocated",
                         file: file,
                         line: line)
        }
    }
    

    // Convenience method for memory leak validation
    /// - Parameters:
    ///   - obj: Any Object
    ///   - file: file
    ///   - line: line
    func expectNoMemoryLeak(obj: AnyObject?, file: StaticString = #filePath, line: UInt = #line) {
        expectNoMemoryLeak(obj: obj as AnyObject, file: file, line: line)
    }

    /// Convenience method for memory leak validation
    /// - Parameters:
    ///   - obj: Any Object
    ///   - file: file
    ///   - line: line
    func expectNoMemoryLeak(obj: Any?, file: StaticString = #filePath, line: UInt = #line) {
        expectNoMemoryLeak(obj: obj as Any, file: file, line: line)
    }

    /// Convenience method for memory leak validation
    /// - Parameters:
    ///   - obj: Any 
    ///   - file: file
    ///   - line: line
    func expectNoMemoryLeak(obj: Any, file: StaticString = #filePath, line: UInt = #line) {
        expectNoMemoryLeak(obj: obj as AnyObject, file: file, line: line)
    }
    
    /// Convenience method for memory leak validation
    /// - Parameters:
    ///   - obj: Any
    ///   - file: file
    ///   - line: line
    func expectNoMemoryLeak(obj: Any, file: StaticString = #filePath, line: UInt = #line) async {
        await expectNoMemoryLeak(obj: obj as AnyObject, file: file, line: line)
    }
    
    
    /// Convenience method for memory leak validation
    /// - Parameters:
    ///   - obj: Any Object
    ///   - file: file
    ///   - line: line
    func expectNoMemoryLeak(obj: AnyObject, 
                            file: StaticString = #filePath, line: UInt = #line) async {
        addTeardownBlock {[weak obj] in
            XCTAssertNil(obj,
                         "the object \(String(describing: obj)) was not deallocated",
                         file: file,
                         line: line)
        }
    }

    /// Convenience method for passing optional expectations
    /// will apply compact map to eliminate optional exp
    /// - Parameters:
    ///   - exp: array of optional expectation
    ///   - timeout: timeout
    func wait(optionalExp exp: [XCTestExpectation?], timeout: TimeInterval) {
        wait(for: exp.compactMap { $0 },
             timeout: timeout)
    }

    /// Sleep using expectation inside
    /// - Parameter timeIntervalSeconds: Sleep interval using seconds
    /// - Note: It's rare occasion that we need it
    func sleepWait(timeIntervalSeconds: Int = 1) {
        let exp = defaultExpectation(name: "Sleep Wait")
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(timeIntervalSeconds)) {
            exp.fulfill()
        }

        wait(for: [exp], timeout: TimeInterval(timeIntervalSeconds + Self.defaultTimmerJitter))
    }
    
    /// Sleep using expectation inside
    /// - Parameter timeIntervalSeconds: Sleep interval using seconds
    /// - Note: It's rare occasion that we need it
    func sleepWaitMS(timeIntervalMS: Int = 100) {
        let exp = defaultExpectation(name: "Sleep Wait")
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(timeIntervalMS)) {
            exp.fulfill()
        }

        wait(for: [exp], timeout: TimeInterval(timeIntervalMS + Self.defaultTimmerJitter))
    }
    
    /// Sleep using expectation inside
    /// - Parameter timeIntervalSeconds: Sleep interval using seconds
    /// - Note: It's rare occasion that we need it
    @available(iOS 16.0, *)
    func sleepAsync<C>(for duration: C.Instant.Duration,
                       tolerance: C.Instant.Duration? = nil,
                       clock: C = ContinuousClock()) async throws where C : Clock {
        try await Task.sleep<C>(for: duration, tolerance: tolerance, clock: clock)
    }
    
    // Waits on a group of expectations for up to the specified timeout,
    /// optionally enforcing their order of fulfillment.
    ///
    /// - Parameters:
    ///     - expectations: An array of expectations that must be fulfilled.
    ///     - seconds: The number of seconds within which all expectations must
    ///         be fulfilled. The default timeout allows the test to run until
    ///         it reaches its execution time allowance.
    ///     - enforceOrderOfFulfillment: If `true`, the expectations specified
    ///         by the `expectations` parameter must be satisfied in the order
    ///         they appear in the array.
    ///
    /// Expectations can only appear in the list once. This function may return
    /// early based on fulfillment of the provided expectations.
    ///
    /// - Note: If you do not specify a timeout when calling this function, it
    ///     is recommended that you enable test timeouts to prevent a runaway
    ///     expectation from hanging the test.
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @nonobjc func fulfillment(of expectations: [XCTestExpectation?],
                              timeout seconds: TimeInterval = .infinity,
                              enforceOrder enforceOrderOfFulfillment: Bool = false) async {
        await fulfillment(of: expectations.compactMap { $0 },
                          timeout: seconds,
                          enforceOrder: enforceOrderOfFulfillment)
    }
}

/// Schedule a block after a delay on a global queue
/// - Parameters:
///   - delay: DispatchTimeInterval
///   - block: Work to pefrom
public func dispatchBlockAfter(_ delay: DispatchTimeInterval, block: @escaping () -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: block)
}
