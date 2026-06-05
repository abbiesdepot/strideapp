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
                // Layar loading singkat saat mengecek database
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
            } else if hasJoinedFamily {
                // Jika sudah punya keluarga, langsung ke Dashboard Utama
                FamilyMainView()
            } else {
                // Jika belum, suruh masukkan kode
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
        
        // Cek di koleksi "familyMembers" apakah ada dokumen dengan userID ini
        db.collection("familyMembers")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        self.hasJoinedFamily = false
                    } else {
                        // Jika ada dokumen yang ditemukan, berarti dia sudah join!
                        self.hasJoinedFamily = !(snapshot?.documents.isEmpty ?? true)
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
