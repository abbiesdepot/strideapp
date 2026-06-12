import SwiftUI
import UserNotifications

@main
struct stride_watch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Stride Watch: notification permission error — \(error.localizedDescription)")
            } else {
                print("Stride Watch: notification permission granted = \(granted)")
            }
        }
    }
}
