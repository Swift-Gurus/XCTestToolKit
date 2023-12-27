import Foundation


class URLProtocolStubBase: URLProtocol {
    static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    static var storage = URLProtocolStubActor()
    
    class func clear() async {
        await updateResponseStubs([])
        await updateReceivedRequests([])
    }

    func nextStub(for request: URLRequest) async -> URLProtocolResponseStub? {
        await Self.nextStub(for: request)
    }

    static func addExpectedStub(_ stub: URLProtocolResponseStub) async {
        await storage.updateResponseStubs(storage.allResponseStubs() + [stub])
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        false
    }

    override func startLoading() {
        Task {
           await emulateLoad()
        }
    }
    
    private func emulateLoad() async {
        let currentRequest = request

        await appendRequest(currentRequest)
        beforeResponse()

        let stub = await nextStub(for: currentRequest)
        if let delayInSec = stub?.delayInSec,
           delayInSec > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delayInSec),
                                              execute: {[weak self] in
                self?.performStart(using: stub, for: currentRequest)
            })
        } else {
            performStart(using: stub, for: currentRequest)
        }
    }

    private func performStart(using stub: URLProtocolResponseStub?,
                              for currentRequest: URLRequest) {
        if let expectedData = stub?.data {
            client?.urlProtocol(self, didLoad: expectedData)
        }

        if let response = urlResponse(for: stub, request: currentRequest) {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let expectedError = stub?.error {
            client?.urlProtocol(self, didFailWithError: expectedError)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    func beforeResponse() {
    }

    private func appendRequest(_ urlRequest: URLRequest) async {
       await Self.storage.appendRequest(request)
    }

    class func updateReceivedRequests(_ requests: [URLRequest]) async {
        await Self.storage.updateReceivedRequests(requests)
    }

    class func allResponseStubs() async -> [URLProtocolResponseStub] {
        await Self.storage.allResponseStubs()
    }

    class func updateResponseStubs(_ stubs: [URLProtocolResponseStub]) async {
        await Self.storage.updateResponseStubs(stubs)
    }

    private func urlResponse(for stub: URLProtocolResponseStub?, request: URLRequest) -> HTTPURLResponse? {
        HTTPURLResponse(url: request.url ?? defaultURLToCrashTests,
                        statusCode: stub?.status ?? 0,
                        httpVersion: "1.0",
                        headerFields: [:])
    }

    var defaultURLToCrashTests: URL {
        URL(fileURLWithPath: "it will crash the tests deliberately")
    }

    override func stopLoading() {}
}

extension URLProtocolStubBase {

    private static func nextStub(for request: URLRequest) async -> URLProtocolResponseStub? {
        let removingResult = await removeStub(for: request, stubs: allResponseStubs())
        await updateResponseStubs(removingResult.stubs)
        return removingResult.stub
    }

    private static func removeStub(for request: URLRequest,
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

    static func requests() async -> [URLRequest]  {
        await Self.storage.receivedRequests()
    }

    private static var _currentRequest: URLRequest?

    private static var currentRequest: URLRequest? {
        get { queue.sync { _currentRequest } }
        set { queue.sync { _currentRequest = newValue } }
    }

    private var currentRequest: URLRequest? {
        Self.currentRequest
    }
}
