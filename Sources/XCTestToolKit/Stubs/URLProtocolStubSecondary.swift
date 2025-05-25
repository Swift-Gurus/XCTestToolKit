import Foundation

public final class URLProtocolStubSecondary: URLProtocolStubBase {
    static var stubsStorage = URLProtocolStubActor()
    public override class var storage: URLProtocolStubActor { stubsStorage }
    
    static var requestObserver: (URLRequest) async -> Void = {_ in }
    
    public class override var requestDidFinishObserver: (URLRequest) async -> Void {
        get { requestObserver }
        set { requestObserver = newValue }
    }
}
