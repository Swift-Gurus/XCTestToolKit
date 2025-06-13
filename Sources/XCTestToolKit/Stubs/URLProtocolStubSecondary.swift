import Foundation

@available(macOS 13.0, *)
public final class URLProtocolStubSecondary: URLProtocolStubBase, @unchecked Sendable {
    static var stubsStorage = URLProtocolStubActor()
    public override class var storage: URLProtocolStubActor { stubsStorage }

    @Locked static var requestObserver: (URLRequest) -> Void = { _ in }

    public class override var requestDidFinishObserver: (URLRequest) -> Void {
        get { requestObserver }
        set { _requestObserver.mutate { _ in newValue }}
    }
}
