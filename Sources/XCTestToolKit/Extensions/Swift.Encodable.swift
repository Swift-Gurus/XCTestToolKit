import Foundation

public extension Encodable {
    
    /// Convenience to convert Encodable to dictionary
    /// - Parameter encoder: encoder
    /// - Returns: [String: Any]
    func toDictionary(using encoder: JSONEncoder = .init()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]
        return result ?? [:]
    }
}
