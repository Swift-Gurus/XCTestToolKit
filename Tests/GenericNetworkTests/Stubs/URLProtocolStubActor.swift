import Foundation

actor URLProtocolStubActor {
    private var requests: [URLRequest] = []
    private var stubs: [URLProtocolResponseStub] = []

    func appendRequest(_ urlRequest: URLRequest) {
        requests = requests.appended(urlRequest)
    }

    func receivedRequests() -> [URLRequest] {
        requests
    }

    func updateReceivedRequests(_ requests: [URLRequest]) {
        self.requests = requests
    }

    func allResponseStubs() -> [URLProtocolResponseStub] {
        stubs
    }

    func updateResponseStubs(_ stubs: [URLProtocolResponseStub]) {
        self.stubs = stubs
    }
}
