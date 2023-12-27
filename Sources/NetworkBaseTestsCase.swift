import XCTest

open class NetworkBaseTestsCase: XCTestCase {

    public var successCode: [Int] = [200]
    public var sessionConfiguration: URLSessionConfiguration = .default
    public var mockSession: URLSession {
        URLSession(configuration: sessionConfiguration)
    }
    
    open override func setUp() async throws {
        await URLProtocolStubBase.clear()
        sessionConfiguration = .default
        sessionConfiguration.protocolClasses = [URLProtocolStubBase.self]
    }
    
    open override func tearDown() async throws {
        await URLProtocolStubBase.clear()
    }
    
    public func addStub(_ stub: URLProtocolResponseStub) async {
        await URLProtocolStubBase.addExpectedStub(stub)
    }
    
    public var allRequests: [URLRequest]  {
        get async {
            await URLProtocolStubBase.requests()
        }
    }

}
