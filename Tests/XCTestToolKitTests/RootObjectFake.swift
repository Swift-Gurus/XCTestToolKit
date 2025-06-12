import Foundation

final class DependantObjectFake {
    var confirmation: () -> Void = {}
}

final class RootObjectFake {
    var dependant: DependantObjectFake = .init()
    var sleepDuration: Duration = .seconds(1)
    func run() async throws {
        Task {
            try await Task.sleep(for: sleepDuration)
            dependant.confirmation()
        }
    }
}
