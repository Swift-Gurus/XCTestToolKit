import Foundation
import XCTest
 #if canImport(FoundationNetworking)
 import FoundationNetworking
 #endif

@MainActor
open class NetworkBaseTestsCase: MultiThreadXCTestCase {
    public var successCode: [Int] = []
    open var cacheFolderURLs: [URL] {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    }
    public var sessionConfigurationStorage = SessionConfigurationStorageMock()
    public var mockSession: URLSession {
        sessionConfigurationStorage.mainSession
    }
    public var secondarySession: URLSession {
        sessionConfigurationStorage.secondarySession
    }
    
    public var fileManager = FileManagerMock()
    public var allRequests: [URLRequest] {
        get async {
            await sessionConfigurationStorage.mainStub.requests()
        }
    }
    
    public var allSecondaryRequests: [URLRequest] {
        get async {
            await sessionConfigurationStorage.secondaryStub.requests()
        }
    }
    open var alwaysClearCacheFolder: Bool {
        false
    }
    public var allRequestURLs: [URL] {
        get async {
            await allRequests.compactMap { $0.url }
        }
    }
    
    public var allSecondaryRequestURLs: [URL] {
        get async {
            await allSecondaryRequests.compactMap { $0.url }
        }
    }

    override open func setUp() async throws {
        try await reset()
    }

    override open func tearDown() async throws {
        try await reset()
    }

    public func addStub(_ stub: URLProtocolResponseStub) async {
        await sessionConfigurationStorage.mainStub.addExpectedStub(stub)
    }

    public func addStubs(_ stubs: [URLProtocolResponseStub]) async {
        for stub in stubs {
            await sessionConfigurationStorage.mainStub.addExpectedStub(stub)
        }
    }
    
    public func addSecondaryStub(_ stub: URLProtocolResponseStub) async {
        await sessionConfigurationStorage.secondaryStub.addExpectedStub(stub)
    }
    
    public func addSecondaryStubs(_ stubs: [URLProtocolResponseStub]) async {
        for stub in stubs {
            await addSecondaryStub(stub)
        }
    }
    
    
    public func clearAllSessionRequests() async {
        await sessionConfigurationStorage.mainStub.clearRequests()
    }
    
    
    
    public func setObserveRequests(_ numberOfRequests: Int) -> XCTestExpectation {
        let exp = expectation(description: "Request Observing")
        exp.expectedFulfillmentCount = numberOfRequests > 0 ? numberOfRequests : 1
        exp.isInverted = numberOfRequests == 0
        observeRequests { _ in
            exp.fulfill()
        }
        
        return exp
    }
    
    public func observeRequests(_ closure: @escaping (URLRequest) -> Void) {
        sessionConfigurationStorage.mainStub.requestDidFinishObserver = closure
    }
    
    public func setObserveSecondaryRequests(_ numberOfRequests: Int) -> XCTestExpectation {
        let exp = expectation(description: "Secondary Request Observing")
        exp.expectedFulfillmentCount = numberOfRequests
        observeSecondaryRequests { _ in
            exp.fulfill()
        }
        
        return exp
    }
    
    public func observeSecondaryRequests(_ closure: @escaping (URLRequest) async -> Void) {
        sessionConfigurationStorage.secondaryStub.requestDidFinishObserver = closure
    }
    
   
    
    
    public func createFile(url: URL, data: Data? = "test".data(using: .utf8)) throws {
        
        try fileManager.createFileWithIntermediateDirectories(url: url, data: data)
    }
    
    @MainActor
    open func reset() async throws {
        stressTestCount = Constants.defaultStressCount
        if alwaysClearCacheFolder {
            try clearCacheFolder()
        }
        
        await sessionConfigurationStorage.clear()
        sessionConfigurationStorage = .init()
        fileManager = .init()
        
        
    }
    
    
    public func clearCacheFolder() throws {
        try fileManager.clearFolders(url: cacheFolderURLs)
        try removeCacheFolder()
    }
    
    public func removeCacheFolder() throws {
        for url in cacheFolderURLs {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            } 
        }
    }
}
