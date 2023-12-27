import Foundation

extension Dictionary {
    var serializedData: Data {
        get throws {
            try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        }
    }
}
