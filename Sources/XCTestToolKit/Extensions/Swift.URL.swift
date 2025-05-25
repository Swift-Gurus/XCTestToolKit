import Foundation

public extension URL {
    struct URLCreateError: Error {}

    /// Convenience init with throw for unit testing
    /// to avoid force unwrapping
    /// - Parameter urlString: URL string
    init(urlString: String) {
        guard let url = URL(string: urlString) else {
            fatalError("Unexpected error, could not create URL")
        }
        
        self = url
    }
}

public extension URL {
    static var mockURL: URL {
        .init(urlString: "http://nothing.to.show")
    }
}

extension URL: Comparable {
    public static func < (lhs: URL, rhs: URL) -> Bool {
        lhs.absoluteString < rhs.absoluteString
    }
    
    
}
