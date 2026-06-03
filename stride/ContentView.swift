//
//  ContentView.swift
//  stride
//
//  Created by abbie on 02/06/26.
//

import FirebaseCore
import SwiftUI

struct ContentView: View {
    @StateObject private var authEngine = AuthViewModel()
    init() {
        FirebaseApp.configure()
    }

    var body: some View {
        RootView()
            .environmentObject(authEngine)
    }
}

#Preview {
    ContentView()
}
