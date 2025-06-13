import Foundation

public protocol Confirmable {
    func confirm(count: Int)
}

public extension Confirmable {
    func confirm() {
        confirm(count: 1)
    }
}

public struct AsyncConfirmation: Confirmable {
    let expectedCount: Int
    let name: String
    private(set) var actualCount: Locked<Int> = .init(rawValue: 0)

    init(expectedCount: Int, name: String) {
        self.expectedCount = expectedCount
        self.name = name
    }

    public func confirm(count: Int) {
        actualCount.mutate { $0 + count }
    }

    public func callAsFunction(count: Int = 1) {
        confirm(count: count)
    }
}

extension AsyncConfirmation {
    var completed: Bool {
        expectedCount <= actualCount.rawValue
    }

}
