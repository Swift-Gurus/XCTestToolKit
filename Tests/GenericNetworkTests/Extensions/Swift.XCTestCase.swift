
import Foundation
import XCTest
@available(iOS 13.0, *)

public func XCTAssertThrowsErrorAsync(_ block: () async throws -> Void,
                                      catchBlock: ((Error) -> Void)? = nil,
                                      _ message: @autoclosure () -> String = "",
                                      file: StaticString = #filePath,
                                      line: UInt = #line) async {
    do {
        try await block()
        XCTFail("Expect to throw an error but was success", file: file, line: line)
    } catch {
        catchBlock?(error)
    }
}
