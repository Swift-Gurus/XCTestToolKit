import Foundation

public extension Dictionary {
    /// Serialization into data by using old JSONSerialization
    var serializedData: Data {
        get throws {
            try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        }
    }
    
    /// Convert to json string
    var jsonString: String {
        get throws {
            try String(data: serializedData, encoding: .utf8) ?? ""
        }
    }
}
