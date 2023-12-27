import XCTest
@testable import GenericNetwork

struct FactoryMock: RequestFactory {
    typealias RequestType = String
    
    func request(for type: String) throws -> URLRequestConvertible {
        MockRequest()
    }
}

final class GenericNetworkTests: XCTestCase {
    
    var successCode: [Int] = [200]
    var sessionConfiguration: URLSessionConfiguration = .default
    var mockSession: URLSession {
        URLSession(configuration: sessionConfiguration)
    }
    var sut: GenericNetwork<FactoryMock> {
        .init(adapter: GenericResponseAdapter(successCodeRange: successCode), 
              urlSession: mockSession,
              factory: FactoryMock())
    }
    
    override func setUp() async throws {
        await URLProtocolStubBase.clear()
        sessionConfiguration = .default
        sessionConfiguration.protocolClasses = [URLProtocolStubBase.self]
    }
    
    
    override func tearDown() async throws {
        await URLProtocolStubBase.clear()
    }
    
    func test_returns_decoded_object() async throws {
        let stub = try URLProtocolResponseStub(data: ["name": "name"].serializedData)
        await addStub(stub)
        let object: ExpectedStruct = try await sut.data(for: "doesnt matter")
        XCTAssertEqual(object.name, "name")
    }
    
    func test_throws_error_if_serialization_fails() async throws  {
        let stub = URLProtocolResponseStub(data: Data())
        await addStub(stub)
        
        await XCTAssertThrowsErrorAsync {
            let _: ExpectedStruct = try await sut.data(for: "doesnt matter")
        }
       
    }
    
    
    func test_throws_error_if_not_success_code() async throws {
        let stub = URLProtocolResponseStub(data: Data(), status: 400)
        await addStub(stub)
        
        await XCTAssertThrowsErrorAsync {
            let _: ExpectedStruct = try await sut.data(for: "doesnt matter")
        }
    }

}


private extension GenericNetworkTests {
    func addStub(_ stub: URLProtocolResponseStub) async {
        await URLProtocolStubBase.addExpectedStub(stub)
    }
}


private struct ExpectedStruct: Decodable {
    let name: String
}
