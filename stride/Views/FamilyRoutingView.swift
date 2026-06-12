//
//  FamilyRoutingView.swift
//  stride
//
//  Created by Michelle Wijaya on 05/06/26.
//

import SwiftUI
import FirebaseFirestore

struct FamilyRoutingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var isChecking = true
    @State private var hasJoinedFamily = false
    
    var body: some View {
        Group {
            if isChecking {
                ZStack {
                    Color.strideBackground.ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .stridePrimary))
                            .scaleEffect(1.5)
                        Text("Memuat data keluarga...")
                            .font(.system(size: 14))
                            .foregroundColor(.strideTextSecondary)
                    }
                }
            } else if authViewModel.isInCareCircle {
                FamilyMainView()
            } else {
                NavigationStack {
                    JoinCareCircleView()
                }
            }
        }
        .onAppear {
            checkFamilyStatus()
        }
    }
    
    private func checkFamilyStatus() {
        guard let userID = authViewModel.currentUser?.id else {
            isChecking = false
            return
        }
        
        let db = Firestore.firestore()
        
        // Listen to changes in familyMembers for this user
        db.collection("familyMembers")
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        authViewModel.isInCareCircle = false
                    } else {
                        authViewModel.isInCareCircle = !(snapshot?.documents.isEmpty ?? true)
                    }
                    self.isChecking = false
                }
            }
    }
}


#Preview {
    FamilyRoutingView()
        .environmentObject(AuthViewModel())
}
