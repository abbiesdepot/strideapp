//
//  strideApp.swift
//  stride
//
//  Created by abbie on 02/06/26.
//

import SwiftUI
import FirebaseCore

@main
struct strideApp: App {
    
    // Create our authentication lifecycle manager
    @StateObject private var authEngine = AuthViewModel()
    
    init() {
        // Safe check: Only initialize Firebase if it isn't already running
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("Stride Backend: Firebase successfully initialized.")
        }
        // Initialize WatchSessionManager to start listening to Apple Watch
        _ = WatchSessionManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            // Send the user directly to RootView as the application gateway
            RootView()
                // Pass our auth logic down so all subviews can access it
                .environmentObject(authEngine)
        }
    }
}
