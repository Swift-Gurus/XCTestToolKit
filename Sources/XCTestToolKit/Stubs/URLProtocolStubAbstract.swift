import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

open class URLProtocolStubAbstract: URLProtocol {
    override open class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override open class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        false
    }
}
