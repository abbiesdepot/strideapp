//
//  AuthViewModel.swift
//  stride
//
//  Created by abbie on 03/06/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: StrideUser? = nil
    @Published var isSessionChecking: Bool = true
    @Published var initializationError: String? = nil
    
    private let database = Firestore.firestore()
    private var authenticationListener: AuthStateDidChangeListenerHandle?
    
    init() {
        monitorAuthenticationState()
    }
    
    func monitorAuthenticationState() {
        self.isSessionChecking = true
        authenticationListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            if let user = user {
                Task {
                    await self.synchronizeUserProfile(uid: user.uid)
                }
            } else {
                self.currentUser = nil
                self.isSessionChecking = false
            }
        }
    }
    
    func synchronizeUserProfile(uid: String) async {
        do {
            let snapshot = try await database.collection("users").document(uid).getDocument()
            if snapshot.exists {
                self.currentUser = try snapshot.data(as: StrideUser.self)
            } else {
                self.currentUser = nil
            }
        } catch {
            self.initializationError = "Error parsing profile data: \(error.localizedDescription)"
            self.currentUser = nil
        }
        self.isSessionChecking = false
    }
    
    func signOutSession() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
        } catch {
            print("Failed to gracefully teardown auth context session: \(error.localizedDescription)")
        }
    }
    
    deinit {
        if let listener = authenticationListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
