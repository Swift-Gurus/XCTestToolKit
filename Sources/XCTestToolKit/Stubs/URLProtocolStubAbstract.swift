import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

open class URLProtocolStubAbstract: URLProtocol {
    public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: (any URLProtocolClient)?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    override open class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override open class func requestIsCacheEquivalent(_ requestA: URLRequest, to requestB: URLRequest) -> Bool {
        false
    }
}
