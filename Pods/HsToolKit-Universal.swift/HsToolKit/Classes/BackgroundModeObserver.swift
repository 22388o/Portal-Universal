import RxSwift
import Foundation

public class BackgroundModeObserver {
    public static let shared = BackgroundModeObserver()

    private let foregroundFromExpiredBackgroundSubject = PublishSubject<Void>()
    #if os(iOS)
    private var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    #endif

    init() {
        #if os(iOS)
        NotificationCenter.default.addObserver(self, selector: #selector(appCameToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        #endif
    }

    @objc private func appCameToBackground() {
        #if os(iOS)
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
        }
        #endif
    }

    @objc private func appCameToForeground() {
        #if os(iOS)
        if backgroundTask != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskIdentifier.invalid
        } else {
            foregroundFromExpiredBackgroundSubject.onNext(())
        }
        #endif
    }

    public var foregroundFromExpiredBackgroundObservable: Observable<Void> {
        foregroundFromExpiredBackgroundSubject.asObservable()
    }

}
