import Foundation


@propertyWrapper
struct Locked<T>: RawRepresentable {
    var wrappedValue: T {
        get { rawValue }
    }
    
    var rawValue: T {
        lock.withLock { storage.rawValue }
    }
    private var storage: Storage<T>
    private let lock: NSLock
    
    init(wrappedValue: T) {
        self.init(rawValue: wrappedValue)
    }
    
    init(rawValue: T) {
        lock = .init()
        storage = .init(rawValue: rawValue)
    }
    
    @discardableResult
    nonmutating func mutate(_ update: (T) -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        storage.rawValue = update(storage.rawValue)
        return storage.rawValue
    }
}


private final class Storage<T>: RawRepresentable {
    var rawValue: T
    
    init(rawValue: T) {
        self.rawValue = rawValue
    }
}
