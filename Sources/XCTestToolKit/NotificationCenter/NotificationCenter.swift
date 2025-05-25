import Foundation
#if canImport(UIKit)
import UIKit

public extension NotificationCenter {
    
    func postNotification(name: Notification.Name) {
        post(.init(name: name))
    }
    
    func emulateForegroundEvent() {
        postNotification(name: UIApplication.didBecomeActiveNotification)
    }
    
    func emulateBackgroundEvent() {
        postNotification(name: UIApplication.didEnterBackgroundNotification)
    }
    
    func emulateWillResignActive() {
        postNotification(name: UIApplication.willResignActiveNotification)
    }
}

#endif
