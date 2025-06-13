import Foundation

@available(macOS 13.0, *)
public final class SessionConfigurationStorageMock {
    public var mainConfiguration: URLSessionConfiguration = .default
    public var secondaryConfiguration: URLSessionConfiguration = .default
    public var mainSession: URLSession {
        URLSession(configuration: mainConfiguration)
    }

    public var mainStub: URLProtocolStubBase.Type {
        URLProtocolStubMain.self
    }

    public var secondaryStub: URLProtocolStubBase.Type {
        URLProtocolStubSecondary.self
    }

    public var secondarySession: URLSession {
        URLSession(configuration: secondaryConfiguration)
    }
    public init() {
        mainConfiguration.protocolClasses = [URLProtocolStubMain.self]
        secondaryConfiguration.protocolClasses = [URLProtocolStubSecondary.self]
        clear()
    }

    public func clear() {
        mainStub.clear()
        secondaryStub.clear()
    }

    deinit {
        clear()
    }
}
