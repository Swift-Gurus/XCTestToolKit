import Foundation

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
    }
    
    @MainActor
    public func clear() async {
        await mainStub.clear()
        await secondaryStub.clear()
    }
}
