import Foundation
@testable import GenericNetwork

struct MockRequest: URLRequestConvertible, Equatable {
   
    
    var baseURL: String = "www.myApi.com"
    var path: String? = "/console"
    var parameters: [String: String] =
         ["role": "admin", "access": "full"]

    var headers: [String: String] = ["username": "admin", "password": "12345"]

    var body: Data? = {
        guard let data = "Test".data(using: .utf8) else {
            fatalError()
        }
        return data
    }()

    var method: RequestMethod = .get
    var scheme: RequestScheme? = .https
    var port: Int? = 980
    var requestTimeout: TimeInterval? = 60
    var id: String = UUID().uuidString

    var requestPolicyTag: Int = 0
    var assumesHTTP3Capable = false
    var requestType: String?
}


extension MockRequest {
    static var expectedFullBaseURLString: String {
        "https://baseURL.com:980/path?id=id"
    }
    
    static var expectedURLString: String {
        "https://www.myApi.com:980/console"
    }

}
