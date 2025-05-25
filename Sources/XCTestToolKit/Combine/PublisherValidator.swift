import Combine
import Foundation
import XCTest

/// Class helper to validate publishers behaviour
open class PublisherValidator<Input, Failure: Error>: Subscriber {
    public typealias Input = Input
    public typealias Failure = Failure
    public typealias State = Subscribers.Completion<Failure>

    public private(set) var subscriptionsReceived: [Subscription] = []
    public private(set) var inputsReceived: [Input] = []
    public private(set) var statesReceived: [State] = []

    public var demand: Subscribers.Demand = .unlimited
    public var dynamicDemand: Subscribers.Demand = .none
    public let receiveValueExp: XCTestExpectation
    public let receiveCompletionExp: XCTestExpectation

    public init(numberOfExpectedEvents: Int,
                receiveCompletion: Bool = true,
                expectedDemand: Subscribers.Demand? = nil) {
        let defaultDemand: Subscribers.Demand = numberOfExpectedEvents == 0 ? .unlimited : .max(numberOfExpectedEvents)
        demand = expectedDemand ?? defaultDemand
        receiveValueExp = .init(name: "value.expectation")
        receiveValueExp.isInverted = numberOfExpectedEvents <= 0
        receiveValueExp.expectedFulfillmentCount = receiveValueExp.isInverted ? 1 : numberOfExpectedEvents

        receiveCompletionExp = .init(name: "completion.expectation")
        receiveCompletionExp.isInverted = !receiveCompletion
    }

    public func receive(subscription: Subscription) {
        subscription.request(demand)
    }

    public func receive(_ input: Input) -> Subscribers.Demand {
        inputsReceived.append(input)
        receiveValueExp.fulfill()
        return dynamicDemand
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        statesReceived.append(completion)
        receiveCompletionExp.fulfill()
    }

    public func reset() {
        statesReceived = []
        inputsReceived = []
        subscriptionsReceived = []
    }
}
