import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct URLProtocolResponseStub {
    public var data: Data?
    public var status: Int = 200
    public var error: Error?
    public var url: String?
    public var delayInSec: Int = 0

    public init(data: Data? = nil,
                status: Int = 200,
                error: Error? = nil,
                url: String? = nil,
                delayInSec: Int = 0) {
        self.data = data
        self.status = status
        self.error = error
        self.url = url
        self.delayInSec = delayInSec
    }
    
    public func new(with data: Data?) -> Self {
        .init(data: data, status: status, error: error, url: url)
    }

    public func new(with status: Int) -> Self {
        .init(data: data, status: status, error: error, url: url)
    }

    public func new(with error: Error?) -> Self {
        .init(data: data, status: status, error: error, url: url)
    }
}
