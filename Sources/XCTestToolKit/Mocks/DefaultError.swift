import Foundation

/// Default Mock error
public struct DefaultError: Error {
    let message: String
    /// Initializer
    public init(message: String = "") {
        self.message = message
    }
}
