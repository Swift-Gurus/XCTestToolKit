import Foundation

public extension FileManager {
    func clearFolders(url: [URL]) throws {
        try url.forEach(clearFolder)
    }
    
    func createFileWithIntermediateDirectories(url: URL, data: Data?) throws {
        createFile(atPath: url.path, contents: data)
    }
    
    func clearFolder(url: URL) throws {
        guard fileExists(atPath: url.path) else {
            return
        }
        try contentsOfDirectory(atPath: url.path).forEach {
            let itemURL = url.appendingPathComponent($0)
            if itemURL.isMediaFile {
                try removeItem(atPath: itemURL.path)
            } 
        }
    }
}


private extension URL {
    var isMediaFile: Bool {
        pathExtension == "mp4" ||
        pathExtension == "png" ||
        pathExtension == "html" ||
        pathExtension == "js" ||
        pathExtension == "jpg"
    }
}
