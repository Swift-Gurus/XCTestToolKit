import Foundation
import XCTest

public extension XCTestExpectation {
    /// Convenience method to create object with assertOverfulfill value
    /// - Parameters:
    ///   - name: Description
    ///   - assertOverfulfill: should assert on overfulfill
    convenience init(name: String, assertOverfulfill: Bool = true ) {
        self.init(description: name)
        self.assertForOverFulfill = assertOverfulfill
    }
}
