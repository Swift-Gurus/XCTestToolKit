import Foundation
public let defaultBufferSize: Int = 4_048 * 1000 * 2
public extension InputStream {
    
    func data(bufferSize: Int = defaultBufferSize) throws -> Data {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        self.open()
        let bytesRead = read(buffer, maxLength: bufferSize)
        return Data(bytes: buffer, count: bytesRead)
    }
    
    func decodable<T: Decodable>(bufferSize: Int = defaultBufferSize) throws -> T {
        let camelCaseDecoder = CustomDateJSONDecoder()
   
        camelCaseDecoder.keyDecodingStrategy = .convertFromSnakeCase
    
        let defaultDecoder = CustomDateJSONDecoder()

        let data = try data(bufferSize: bufferSize)
        let obj: T? = try camelCaseDecoder.decode(T.self, from: data)
        return try obj ?? defaultDecoder.decode(T.self, from: data)
    }
    
    
}

private class CustomDateJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        dateDecodingStrategy = .iso8601
    }
}

public extension URLRequest {
    
    func data(bufferSize: Int = defaultBufferSize) throws -> Data {
        guard let httpBodyStream else {
            throw DefaultError(message: "No Stream Attached")
        }
        return try httpBodyStream.data()
    }
    
    func decodable<T: Decodable>(bufferSize: Int = defaultBufferSize) throws -> T {
        guard let httpBodyStream else {
            throw DefaultError(message: "No Stream Attached")
        }
        return try httpBodyStream.decodable(bufferSize: bufferSize)
    }
}
