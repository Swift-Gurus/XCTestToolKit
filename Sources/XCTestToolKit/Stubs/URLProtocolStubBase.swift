import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@MainActor
open class URLProtocolStubBase: URLProtocolStubAbstract, @unchecked Sendable {
    static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    
    open class var storage: URLProtocolStubActor {
        fatalError("Subclasses must implement")
    }
    open class var requestDidFinishObserver: (URLRequest) async -> Void {
        get { fatalError("Subclasses must implement") }
        set { fatalError("Subclasses must implement") }
        
    }
    var defaultURLToCrashTests: URL {
        URL(fileURLWithPath: "it will crash the tests deliberately")
    }
    
    
    open class func clearRequests() async {
        await updateResponseStubs([])
        await updateReceivedRequests([])
    }
    
    open class func clear() async {
        await clearRequests()
        requestDidFinishObserver = { _ in }
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

    public static func addExpectedStub(_ stub: URLProtocolResponseStub) async {
        await storage.updateResponseStubs(storage.allResponseStubs() + [stub])
    }

    func nextStub(for request: URLRequest) async -> URLProtocolResponseStub? {
        await Self.nextStub(for: request)
    }

    override open func startLoading() {
        Task {
           await emulateLoad()
        }
    }

    func beforeResponse() {
    }

    override open func stopLoading() {}
}

// swiftlint:disable no_grouping_extension
extension URLProtocolStubBase {
    private static var _currentRequest: URLRequest?

    private static var currentRequest: URLRequest? {
        get { queue.sync { _currentRequest } }
        set { queue.sync { _currentRequest = newValue } }
    }

    private var currentRequest: URLRequest? {
        Self.currentRequest
    }

    static func nextStub(for request: URLRequest) async -> URLProtocolResponseStub? {
        await Self.storage.nextStub(for: request)
    }

    static func requests() async -> [URLRequest] {
        await Self.storage.receivedRequests()
    }

    private func appendRequest(_ urlRequest: URLRequest) async {
       await Self.storage.appendRequest(request)
    }

    private func urlResponse(for stub: URLProtocolResponseStub?, request: URLRequest) -> HTTPURLResponse? {
        HTTPURLResponse(url: request.url ?? defaultURLToCrashTests,
                        statusCode: stub?.status ?? 0,
                        httpVersion: "1.0",
                        headerFields: [:])
    }

    private func emulateLoad() async {
        let currentRequest = request

        await appendRequest(currentRequest)
        beforeResponse()

        let stub = await nextStub(for: currentRequest)
        
        if let delayInSec = stub?.delayInSec,
           delayInSec > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delayInSec)) {[weak self] in
                self?.performStart(using: stub, for: currentRequest)
            }
        } else {
            performStart(using: stub, for: currentRequest)
        }
    }

    private func performStart(using stub: URLProtocolResponseStub?,
                              for currentRequest: URLRequest) {
        if let hang = stub?.emulateHang,
           hang == true {
            return
        }
        
        if let expectedData = stub?.data {
            client?.urlProtocol(self, didLoad: expectedData)
        }

        if let response = urlResponse(for: stub, request: currentRequest) {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        } else {
            fatalError("Should always have a response")
        }

        
        if let expectedError = stub?.error {
            client?.urlProtocol(self, didFailWithError: expectedError)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        Task { await Self.requestDidFinishObserver(currentRequest) }
       
    }
}
