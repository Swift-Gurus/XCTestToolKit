import Foundation

public final class FileManagerMock: FileManager {
    public var returnFileExist = false
    public var callSuper = false
    public var destinations: [URL] = []
    public var sources:[URL] = []
    public var expectedError: Error?
    public var attributes: [String: [FileAttributeKey: Any]] = [:]
    public var contents: [String] = []
    public var removeItemsCalls: [String] = []
    private let syncQueue = DispatchQueue(label: "FileManagerMock.serial")
    public override func fileExists(atPath path: String) -> Bool {
        callSuper ? super.fileExists(atPath: path) : returnFileExist
    }
    
    public override func moveItem(at srcURL: URL, to dstURL: URL) throws {
        syncQueue.sync {
            destinations.append(dstURL)
            sources.append(srcURL)
        }
        
        
        if let expectedError {
            throw expectedError
        }
        
        if callSuper {
            try super.moveItem(at: srcURL, to: dstURL)
        }
    }
    
    public override func attributesOfItem(atPath path: String) throws -> [FileAttributeKey : Any] {
        guard !callSuper else {
            return try super.attributesOfItem(atPath: path)
        }
        
        return attributes[path] ?? [:]
    }
    
    public override func contentsOfDirectory(atPath path: String) throws -> [String] {
        guard !callSuper else {
            return try super.contentsOfDirectory(atPath: path)
        }
        
        return contents
    }
    
    public override func removeItem(atPath path: String) throws {
        syncQueue.sync {
            removeItemsCalls.append(path)
        }
        
        if callSuper {
            try super.removeItem(atPath: path)
        }        
    }
}
