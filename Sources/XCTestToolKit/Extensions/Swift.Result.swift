import Foundation

public extension Result where Failure == Error {
    /// Convenience factory method for defaultError
    static var defaultMockedError: Self {
        .failure(DefaultError())
    }
}
