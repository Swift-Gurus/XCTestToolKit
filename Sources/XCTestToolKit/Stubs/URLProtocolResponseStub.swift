import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Representation o server response
public struct URLProtocolResponseStub: Sendable {
    /// Response data
    public var data: Data?

    /// Response status
    public var status: Int = 200

    /// Response error
    public var error: Error?

    /// Request URL
    public var url: String?

    /// Delay of the response
    public var delayInSec: Int = 0
    
    
    
    /// Emulates if the request has no response/long response
    public var emulateHang: Bool = false

    /// Initialization
    /// - Parameters:
    ///   - data: Data
    ///   - status: Int (default 200)
    ///   - error: Error
    ///   - url: String
    ///   - delayInSec: Int
    public init(data: Data? = nil,
                status: Int = 200,
                error: Error? = nil,
                url: String? = nil,
                delayInSec: Int = 0,
                emulateHang: Bool = false) {
        self.data = data
        self.status = status
        self.error = error
        self.url = url
        self.delayInSec = delayInSec
        self.emulateHang = emulateHang
    }

    /// Convenience constructor
    /// - Parameter data: Data
    /// - Returns: New response with updated Data
    public func new(with data: Data?) -> Self {
        .init(data: data, status: status, error: error, url: url)
    }

    /// Convenience constructor
    /// - Parameter status: Response status
    /// - Returns: New response with updated Status
    public func new(with status: Int) -> Self {
        .init(data: data, status: status, error: error, url: url)
    }

    /// Convenience constructor
    /// - Parameter error: Response error
    /// - Returns: New response with updated error
    public func new(with error: Error?) -> Self {
        .init(data: data, status: status, error: error, url: url)
    }
}
