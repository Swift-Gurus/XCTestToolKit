import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@available(macOS 13.0, *)
open class URLProtocolStubBase: URLProtocolStubAbstract, @unchecked Sendable {
    static let queue = DispatchQueue(label: "URLProtocolStub.queue")

    open class var storage: URLProtocolStubActor {
        fatalError("Subclasses must implement")
    }
    open class var requestDidFinishObserver: (URLRequest) -> Void {
        get { fatalError("Subclasses must implement") }
        set { fatalError("Subclasses must implement") }

    }
    var defaultURLToCrashTests: URL {
        URL(fileURLWithPath: "it will crash the tests deliberately")
    }

    open class func clearRequests() {
        updateResponseStubs([])
        updateReceivedRequests([])
    }

    open class func clear() {
        clearRequests()
        requestDidFinishObserver = { _ in }
    }

    class func updateReceivedRequests(_ requests: [URLRequest]) {
        Self.storage.updateReceivedRequests(requests)
    }

    class func allResponseStubs() async -> [URLProtocolResponseStub] {
        Self.storage.allResponseStubs()
    }

    class func updateResponseStubs(_ stubs: [URLProtocolResponseStub]) {
        Self.storage.updateResponseStubs(stubs)
    }

    public static func addExpectedStub(_ stub: URLProtocolResponseStub) {
        storage.updateResponseStubs(storage.allResponseStubs() + [stub])
    }

    func nextStub(for request: URLRequest) -> URLProtocolResponseStub? {
        Self.nextStub(for: request)
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
@available(macOS 13.0, *)
extension URLProtocolStubBase {
    @Locked private static var request: URLRequest?

    private static var currentRequest: URLRequest? {
        get { request }
        set { _request.mutate { _ in newValue } }
    }

    private var currentRequest: URLRequest? {
        Self.currentRequest
    }

    static func nextStub(for request: URLRequest) -> URLProtocolResponseStub? {
        Self.storage.nextStub(for: request)
    }

    static func requests() async -> [URLRequest] {
        Self.storage.receivedRequests()
    }

    private func appendRequest(_ urlRequest: URLRequest) {
        Self.storage.appendRequest(request)
    }

    private func urlResponse(for stub: URLProtocolResponseStub?, request: URLRequest) -> HTTPURLResponse? {
        HTTPURLResponse(url: request.url ?? defaultURLToCrashTests,
                        statusCode: stub?.status ?? 0,
                        httpVersion: "1.0",
                        headerFields: [:])
    }

    private func emulateLoad() async {
        let currentRequest = request

        appendRequest(currentRequest)
        beforeResponse()

        let stub = nextStub(for: currentRequest)

        if let delayInSec = stub?.delayInSec,
           delayInSec > 0 {
            try? await Task.sleep(for: .seconds(delayInSec))
        }

        performStart(using: stub, for: currentRequest)
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
        Self.requestDidFinishObserver(currentRequest)

    }
}
