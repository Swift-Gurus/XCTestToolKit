@testable import XCTestToolKit
import Testing

@Suite(.serialized)
struct NetworkObserverTests {
    let stressTestCount = 1000

    @Test func simple() async throws {
        let observer = NetworkObserver()
        _ = try await observer.mockSession.data(for: .init(url: .mockURL))
    }

    @Test
    func test_waits_for_all_main_requests_and_returns_their_values() async throws {
        let observer = NetworkObserver()
        observer.setObserveRequests(stressTestCount)

        try await asyncStress { _ in
            try await observer.mockSession.data(for: .init(url: .mockURL))
        }

        let request = try await observer.allRequests
        #expect(request.count == stressTestCount)

    }

    @Test
    func test_waits_for_all_secondary_requests_and_returns_their_values() async throws {
        let observer = NetworkObserver()
        observer.setObserveSecondaryRequests(stressTestCount)

        try await asyncStress { _ in
            try await observer.secondarySession.data(for: .init(url: .mockURL))
        }

        let request = try await observer.allSecondaryRequestURLs
        #expect(request.count == stressTestCount)

    }

    @Test
    func test_waits_for_all_requests_and_returns_their_values() async throws {
        let observer = NetworkObserver()
        observer.setObserveSecondaryRequests(stressTestCount)
        observer.setObserveRequests(stressTestCount)

        try await asyncStress { _ in
            _ = try await observer.secondarySession.data(for: .init(url: .mockURL))
            _ = try await observer.mockSession.data(for: .init(url: .mockURL))
        }

        let secRequest = try await observer.allSecondaryRequestURLs
        let mainRequest = try await observer.allRequests
        #expect(secRequest.count == stressTestCount)
        #expect(mainRequest.count == stressTestCount)
    }
}
