import Foundation

extension MultiThreadXCTestCase {
    /// Stress Tests Default Values
    enum Constants {
        /// Default number of iterations for multithread stress tests
        static let defaultStressCount = 1_000
        /// Default max sleeping interval of a thread in ms
        static let defaultSleepingInterval: UInt32 = 1_000
    }
}
