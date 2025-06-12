import Foundation
import Testing

@testable import XCTestToolKit

struct RepeatableOperationTests {
    @Test("Runs all the operations and returns result")
    func run_all_operation_should_return_result() async throws {
        @Locked var count: Int = -1
        let result = try await stressRunAsync {
            _count.mutate { $0 + 1 }
        }
    
        #expect(result.sorted() == Array(0..<1000))
    }
}
