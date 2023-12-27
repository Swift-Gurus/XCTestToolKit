import XCTest
@testable import GenericNetwork

class URLRequestConvertibleTests: XCTestCase {
    var request: MockRequest {
        .init()
    }

    var expectedCustomURLString: String {
        MockRequest.expectedURLString
    }

    var expectedBaseURLString: String {
        MockRequest.expectedFullBaseURLString
    }

    func test_adapter_uses_base_url() throws {
        let urlRequest = try request.urlRequest()
        XCTAssertEqual(urlRequest.url?.host, request.baseURL)
    }

    func test_adapter_missing_params() throws {
        var mutableRequest = request
        mutableRequest.parameters = [:]
        let urlRequest = try mutableRequest.urlRequest()
        XCTAssertEqual(urlRequest.url?.absoluteURL.absoluteString, expectedCustomURLString)
    }

    func test_adapter_uses_path() throws {
        let urlRequest = try request.urlRequest()
        XCTAssertEqual(urlRequest.url?.path, request.path)
    }

    func test_adapter_uses_scheme() throws {
        let urlRequest = try request.urlRequest()
        XCTAssertEqual(urlRequest.url?.scheme, request.scheme?.rawValue)
    }

    func test_adapter_uses_headers() throws {
        let urlRequest = try request.urlRequest()
        XCTAssertEqual(urlRequest.allHTTPHeaderFields ?? [:], request.headers)
    }

    func test_adapter_uses_method() throws {
        let urlRequest = try request.urlRequest()
        XCTAssertEqual(urlRequest.httpMethod, request.method.rawValue.uppercased())
    }

    func test_adapter_uses_body() throws {
        let urlRequest = try request.urlRequest()
        XCTAssertEqual(urlRequest.httpBody, request.body)
    }

    func test_url_already_contains_scheme() throws {
        var mutableRequest = request
        mutableRequest.parameters = [:]
        mutableRequest.baseURL = expectedCustomURLString
        let urlRequest = try mutableRequest.urlRequest()
        XCTAssertEqual(urlRequest.url?.absoluteURL.absoluteString, expectedCustomURLString)
    }

    func test_request_is_created_from_a_string() throws {
        let request = MockRequest(baseURL: expectedBaseURLString)
        let urlRequest = try request.urlRequest()
        XCTAssertEqual(urlRequest.url?.absoluteURL.absoluteString, expectedBaseURLString)
    }

    func test_request_wrong_path_throws_error() throws {
        var request = MockRequest(baseURL: "")
        request.path = "//"
        request.parameters = [:]
        request.headers = [:]
        request.scheme = nil
        request.port = nil
        request.body = nil
        XCTAssertThrowsError(try request.urlRequest())
    }

    func test_empty_scheme_doesnt_cause_crash() throws {
        var request = MockRequest(baseURL: "")
        request.path = nil
        request.parameters = [:]
        request.headers = [:]
        request.scheme = nil
        request.port = nil
        request.body = nil
        let urlRequest = try request.urlRequest()
        XCTAssertEqual(urlRequest.url?.absoluteURL.absoluteString, "")
    }
}
