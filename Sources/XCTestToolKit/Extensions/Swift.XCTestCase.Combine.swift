import Combine
import Foundation
import XCTest
// swiftlint: disable prefer_nimble

public extension XCTestCase {
    /// Convenience method to validate combine publishers using subscribe
    /// - Parameters:
    ///   - publisher: Publisher
    ///   - expectedEvents: expected events
    ///   - timeout: waiting timeout
    ///   - expectComplete: indicate if the flow is final
    ///   - start: block to perform before wait for expectations
    func validatePublisher<P: Publisher>(_ publisher: P,
                                         expectedEvents: [P.Output],
                                         timeout: TimeInterval,
                                         expectComplete: Bool = true,
                                         expectedDemand: Subscribers.Demand? = nil,
                                         file: StaticString = #filePath,
                                         line: UInt = #line,
                                         start: () -> Void) throws where P.Output: Equatable {
        validatePublisher(publisher,
                          expectNumberOfEvents: expectedEvents.count,
                          timeout: timeout,
                          expectComplete: expectComplete,
                          expectedDemand: expectedDemand,
                          file: file,
                          line: line,
                          start: start) { validator in
            XCTAssertEqual(expectedEvents, validator.inputsReceived, file: file, line: line)
        }
    }

    /// Convenience method to validate combine publishers using subscribe
    /// - Parameters:
    ///   - publisher: Publisher
    ///   - expectNumberOfEvents: number of events to wait
    ///   - timeout: timeout
    ///   - expectComplete: indicate if the flow is final
    ///   - start: block to perform before wait for expectations
    ///   - receivedEvents: received events passed via validator
    func validatePublisher<P: Publisher>(_ publisher: P,
                                         expectNumberOfEvents: Int,
                                         timeout: TimeInterval,
                                         expectComplete: Bool = true,
                                         expectedDemand: Subscribers.Demand? = nil,
                                         file: StaticString = #filePath,
                                         line: UInt = #line,
                                         start: () -> Void = {},
                                         receivedEvents: (PublisherValidator<P.Output, P.Failure>) -> Void) {
        expectNoMemoryLeak(obj: publisher)
        let validator = PublisherValidator<P.Output, P.Failure>(numberOfExpectedEvents: expectNumberOfEvents,
                                                                receiveCompletion: expectComplete,
                                                                expectedDemand: expectedDemand)
        expectNoMemoryLeak(obj: validator, file: file, line: line)

        publisher.subscribe(validator)
        start()
        wait(optionalExp: [validator.receiveValueExp, validator.receiveCompletionExp],
             timeout: timeout)
        receivedEvents(validator)
        validator.reset()
    }
    
    
    /// Convenience method to validate combine publishers using sink
    /// - Parameters:
    ///   - publisher: Publisher
    ///   - expectedEvents: expected events
    ///   - timeout: waiting timeout
    ///   - expectComplete: indicate if the flow is final
    ///   - start: block to perform before wait for expectations
    func validatePublisherSink<P: Publisher>(_ publisher: P,
                                             expectedEvents: [P.Output],
                                             timeout: TimeInterval,
                                             expectComplete: Bool = true,
                                             file: StaticString = #filePath,
                                             line: UInt = #line,
                                             start: () -> Void) throws where P.Output: Equatable {
        validatePublisherSink(publisher,
                              expectNumberOfEvents: expectedEvents.count,
                              timeout: timeout,
                              expectComplete: expectComplete,
                              file: file,
                              line: line,
                              start: start) { validator in
            XCTAssertEqual(expectedEvents, validator.inputsReceived, file: file, line: line)
        }
    }

    
    
    /// Convenience method to validate combine publishers using sink
    /// - Parameters:
    ///   - publisher: Publisher
    ///   - expectNumberOfEvents: number of events to wait
    ///   - timeout: timeout
    ///   - expectComplete: indicate if the flow is final
    ///   - start: block to perform before wait for expectations
    ///   - receivedEvents: received events passed via validator
    func validatePublisherSink<P: Publisher>(_ publisher: P,
                                             expectNumberOfEvents: Int,
                                             timeout: TimeInterval,
                                             expectComplete: Bool = true,
                                             file: StaticString = #filePath,
                                             line: UInt = #line,
                                             start: () -> Void = {},
                                             receivedEvents: (PublisherValidator<P.Output, P.Failure>) -> Void) {
        expectNoMemoryLeak(obj: publisher)
        let validator = PublisherValidator<P.Output, P.Failure>(numberOfExpectedEvents: expectNumberOfEvents,
                                                                receiveCompletion: expectComplete)
        expectNoMemoryLeak(obj: validator, file: file, line: line)

        var cancellable = publisher.sink { completion in
            validator.receive(completion: completion)
        } receiveValue: { output in
            _ = validator.receive(output)
        }
        start()
        wait(optionalExp: [validator.receiveValueExp, validator.receiveCompletionExp],
             timeout: timeout)
        receivedEvents(validator)
        validator.reset()
    }
    
}
