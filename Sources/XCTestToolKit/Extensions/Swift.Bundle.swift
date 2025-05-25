import Foundation

public extension Bundle {
    func getXMLContentData(for filename: String) throws -> Data {
        let content = try url(forResource: filename, withExtension: "xml")
                                    .map { try Data(contentsOf: $0) }

        guard let content  else {
            throw DefaultError(message: "Content not found for \(filename)")
        }

        return content
    }

    func getXMLContent(for filename: String) throws -> String {
        guard let content = try String(data: getXMLContentData(for: filename), encoding: .utf8)  else {
            throw DefaultError(message: "Content not found for \(filename)")
        }

        return content
    }
}
