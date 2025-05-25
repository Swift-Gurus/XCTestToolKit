import Foundation

public final class URLProtocolStubMain: URLProtocolStubBase {
    static var stubsStorage = URLProtocolStubActor()
    static var requestObserver: (URLRequest) async -> Void = {_ in }
    
    public class override var requestDidFinishObserver: (URLRequest) async -> Void {
        get { requestObserver }
        set { requestObserver = newValue }
    }
    public override class var storage: URLProtocolStubActor { stubsStorage }
}
