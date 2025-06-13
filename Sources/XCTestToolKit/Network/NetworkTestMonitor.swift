import Foundation

/// A utility class for observing and managing network requests during testing.
///
/// It provides:
/// - Request interception and tracking
/// - URLProtocol stubbing support for primary and secondary sessions
/// - Timeout-based confirmation for expected request counts
/// - Cache folder handling
///
/// Designed to work with `SessionConfigurationStorageMock` and `AsyncConfirmation`.
@available(macOS 13.0, *)
public final class NetworkTestMonitor {

    /// Returns the URLs for the cache directories in the user's domain.
    var cacheFolderURLs: [URL] {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    }

    /// Mocked storage for session configurations and stubs.
    public var sessionConfigurationStorage = SessionConfigurationStorageMock()

    /// URLSession used for primary network mocking.
    public var mockSession: URLSession {
        sessionConfigurationStorage.mainSession
    }

    /// URLSession used for secondary network mocking (if needed).
    public var secondarySession: URLSession {
        sessionConfigurationStorage.secondarySession
    }

    /// Internal list of confirmations to track request completion.
    private var confirmations: [AsyncConfirmation] = []

    /// Duration to wait before timing out request confirmations.
    public var requestsWaitingTimeout: Duration = .seconds(1)

    /// FileManager abstraction used to manage file operations during testing.
    public var fileManager = FileManagerMock()

    /// Returns all intercepted primary session requests after awaiting expected confirmations.
    public var allRequests: [URLRequest] {
        get async throws {
            try await waitForAsyncConfirmations(confirmations, duration: requestsWaitingTimeout)
            return await sessionConfigurationStorage.mainStub.requests()
        }
    }

    /// Returns all intercepted secondary session requests after awaiting expected confirmations.
    public var allSecondaryRequests: [URLRequest] {
        get async throws {
            try await waitForAsyncConfirmations(confirmations, duration: requestsWaitingTimeout)
            return await sessionConfigurationStorage.secondaryStub.requests()
        }
    }

    /// Extracts the URLs from all intercepted primary requests.
    public var allRequestURLs: [URL] {
        get async throws {
            try await allRequests.compactMap { $0.url }
        }
    }

    /// Extracts the URLs from all intercepted secondary requests.
    public var allSecondaryRequestURLs: [URL] {
        get async throws {
            try await allSecondaryRequests.compactMap { $0.url }
        }
    }
    
    public init() {}

    /// Adds expected stubs for the primary session.
    public func addStubs(_ stubs: [URLProtocolResponseStub]) {
        for stub in stubs {
            sessionConfigurationStorage.mainStub.addExpectedStub(stub)
        }
    }

    /// Adds expected stubs for the secondary session.
    public func addSecondaryStubs(_ stubs: [URLProtocolResponseStub]) {
        for stub in stubs {
            sessionConfigurationStorage.secondaryStub.addExpectedStub(stub)
        }
    }

    /// Clears the tracked requests for the primary session.
    public func clearAllSessionRequests() async {
        sessionConfigurationStorage.mainStub.clearRequests()
    }

    /// Sets up observation for a specific number of primary requests.
    /// This enables awaiting confirmation during test assertions.
    public func setObserveRequests(_ numberOfRequests: Int) {
        let confirmation = AsyncConfirmation(expectedCount: numberOfRequests,
                                             name: "Main Requests Confirmation")
        observeRequests { _ in confirmation() }
        confirmations.append(confirmation)
    }

    /// Internal: Registers a closure to observe primary session requests.
    func observeRequests(_ closure: @escaping @Sendable (URLRequest) -> Void) {
        sessionConfigurationStorage.mainStub.requestDidFinishObserver = closure
    }

    /// Sets up observation for a specific number of secondary requests.
    public func setObserveSecondaryRequests(_ numberOfRequests: Int) {
        let confirmation = AsyncConfirmation(expectedCount: numberOfRequests,
                                             name: "Secondary Requests Confirmation")
        observeSecondaryRequests { _ in confirmation() }
        confirmations.append(confirmation)
    }

    /// Internal: Registers a closure to observe secondary session requests.
    func observeSecondaryRequests(_ closure: @escaping (URLRequest) -> Void) {
        sessionConfigurationStorage.secondaryStub.requestDidFinishObserver = closure
    }

    /// Creates a file at the given URL with optional data (default is `"test"`).
    public func createFile(url: URL, data: Data? = "test".data(using: .utf8)) throws {
        try fileManager.createFileWithIntermediateDirectories(url: url, data: data)
    }

    /// Clears and removes the contents of all cache folders.
    public func clearCacheFolder() throws {
        try fileManager.clearFolders(url: cacheFolderURLs)
        try removeCacheFolder()
    }

    /// Removes all cache folders entirely.
    public func removeCacheFolder() throws {
        for url in cacheFolderURLs {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
        }
    }
}
