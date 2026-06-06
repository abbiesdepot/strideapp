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
    
    @StateObject private var authEngine = AuthViewModel()
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("Stride Backend: Firebase successfully initialized.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authEngine)
        }
    }
}
