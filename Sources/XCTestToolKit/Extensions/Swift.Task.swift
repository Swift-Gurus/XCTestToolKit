import Foundation

public extension Task where Success == Void, Failure == Never {
    
    static func multipleTasks(number: Int,
                              priority: TaskPriority? = nil,
                              operation: @escaping @Sendable () -> Success) async {
        let range = stride(from: 0, to: number, by: 1)
        await withTaskGroup(of: Void.self) { group in
            range.forEach { _ in
                group.addTask {
                    operation()
                }
            }

            for await _ in group {}
        }
    }
   
}
