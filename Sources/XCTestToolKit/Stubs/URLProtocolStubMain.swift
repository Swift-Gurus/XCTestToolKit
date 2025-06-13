import Foundation

@available(macOS 13.0, *)
public final class URLProtocolStubMain: URLProtocolStubBase, @unchecked Sendable {
    static var stubsStorage = URLProtocolStubActor()
    @Locked static var requestObserver: (URLRequest) -> Void = {_ in }

    public class override var requestDidFinishObserver: (URLRequest) -> Void {
        get { requestObserver }
        set { _requestObserver.mutate { _ in newValue } }
    }
    public override class var storage: URLProtocolStubActor { stubsStorage }
}
