@testable import XCTestToolKit
import Testing

@Suite(.serialized)
struct NetworkObserverTests {
    let stressTestCount = 1000
    var networkMonitor = NetworkTestMonitor()
    @Test func simple() async throws {
        _ = try await networkMonitor.mockSession.data(for: .init(url: .mockURL))
    }

    @Test
    func test_waits_for_all_main_requests_and_returns_their_values() async throws {
        networkMonitor.setObserveRequests(stressTestCount)

        try await asyncStress { _ in
            try await networkMonitor.mockSession.data(for: .init(url: .mockURL))
        }

        let request = try await networkMonitor.allRequests
        #expect(request.count == stressTestCount)

    }

    @Test
    func test_waits_for_all_secondary_requests_and_returns_their_values() async throws {
        networkMonitor.setObserveSecondaryRequests(stressTestCount)

        try await asyncStress { _ in
            try await networkMonitor.secondarySession.data(for: .init(url: .mockURL))
        }

        let request = try await networkMonitor.allSecondaryRequestURLs
        #expect(request.count == stressTestCount)

    }

    @Test
    func test_waits_for_all_requests_and_returns_their_values() async throws {
        networkMonitor.setObserveSecondaryRequests(stressTestCount)
        networkMonitor.setObserveRequests(stressTestCount)

        try await asyncStress { _ in
            _ = try await networkMonitor.secondarySession.data(for: .init(url: .mockURL))
            _ = try await networkMonitor.mockSession.data(for: .init(url: .mockURL))
        }

        let secRequest = try await networkMonitor.allSecondaryRequestURLs
        let mainRequest = try await networkMonitor.allRequests
        #expect(secRequest.count == stressTestCount)
        #expect(mainRequest.count == stressTestCount)
    }

    @Test
    func throws_error_when_no_calls_made() async throws {
        networkMonitor.setObserveSecondaryRequests(stressTestCount)
        try await asyncStress { _ in }
        await #expect(throws: Error.self) {
            _ = try await networkMonitor.allSecondaryRequestURLs

        }
    }
}
