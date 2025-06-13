import Foundation
import XCTest
#if canImport(FoundationNetworking)
 import FoundationNetworking
#endif

@available(macOS 13.0, *)
@MainActor
open class NetworkBaseTestsCase: MultiThreadXCTestCase {
    private var networkObserver = NetworkObserver()
    public var successCode: [Int] = []
    open var cacheFolderURLs: [URL] {
        networkObserver.cacheFolderURLs
    }
    public var mockSession: URLSession {
        networkObserver.mockSession
    }
    public var secondarySession: URLSession {
        networkObserver.secondarySession
    }

    public var fileManager = FileManagerMock()
    public var allRequests: [URLRequest] {
        get async throws {
            try await networkObserver.allRequests
        }
    }

    public var allSecondaryRequests: [URLRequest] {
        get async throws {
            try await networkObserver.allSecondaryRequests
        }
    }
    open var alwaysClearCacheFolder: Bool {
        true
    }
    public var allRequestURLs: [URL] {
        get async throws {
            try await networkObserver.allRequestURLs
        }
    }

    public var allSecondaryRequestURLs: [URL] {
        get async throws {
            try await networkObserver.allSecondaryRequestURLs
        }
    }

    override open func setUp() async throws {
        try await reset()
    }

    override open func tearDown() async throws {
        try await reset()
    }

    public func addStubs(_ stubs: [URLProtocolResponseStub]) {
        networkObserver.addStubs(stubs)
    }

    public func addSecondaryStubs(_ stubs: [URLProtocolResponseStub]) async {
        networkObserver.addSecondaryStubs(stubs)
    }

    public func clearAllSessionRequests() async {
        await networkObserver.clearAllSessionRequests()
    }

    public func setObserveRequests(_ numberOfRequests: Int) {
        networkObserver.setObserveRequests(numberOfRequests)
    }

    public func setObserveSecondaryRequests(_ numberOfRequests: Int) {
        networkObserver.setObserveSecondaryRequests(numberOfRequests)
    }

    public func createFile(url: URL, data: Data? = "test".data(using: .utf8)) throws {
        try networkObserver.createFile(url: url, data: data)
    }

    open func reset() async throws {
        stressTestCount = Constants.defaultStressCount
        if alwaysClearCacheFolder {
            try networkObserver.clearCacheFolder()
        }

        networkObserver = .init()
    }

    public func clearCacheFolder() throws {
        try networkObserver.clearCacheFolder()
    }

    public func removeCacheFolder() throws {
        try networkObserver.removeCacheFolder()
    }
}
