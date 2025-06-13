import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class URLProtocolStubActor {
    @Locked private var requests: [URLRequest] = []
    @Locked private var stubs: [URLProtocolResponseStub] = []

    public init() {}

    func appendRequest(_ urlRequest: URLRequest) {
        _requests.mutate { $0.appended(urlRequest) }
    }

    func receivedRequests() -> [URLRequest] {
        requests
    }

    func updateReceivedRequests(_ requests: [URLRequest]) {
        _requests.mutate { _ in requests }
    }

    func allResponseStubs() -> [URLProtocolResponseStub] {
        stubs
    }

    func updateResponseStubs(_ stubs: [URLProtocolResponseStub]) {
        _stubs.mutate { _ in stubs }
    }

    func nextStub(for request: URLRequest) -> URLProtocolResponseStub? {
        let removingResult = removeStub(for: request, stubs: allResponseStubs())
        updateResponseStubs(removingResult.stubs)
        return removingResult.stub
    }

    private func removeStub(for request: URLRequest,
                            stubs: [URLProtocolResponseStub]) -> (stub: URLProtocolResponseStub?, stubs: [URLProtocolResponseStub]) {
        let stub: URLProtocolResponseStub?
        var stubs = stubs
        if let stubIndex = stubs.firstIndex(where: { $0.url == request.url?.absoluteString && $0.url != nil }) {
            stub = stubs.remove(at: stubIndex)
        } else if let index = stubs.firstIndex(where: { $0.url == nil }) {
            stub = stubs.remove(at: index)
        } else {
            stub = stubs.removedFirstSafely()
        }

        return (stub, stubs)
    }
}
