//
//  FamilyAlertsView.swift
//  stride
//
//  Created by Michelle Wijaya on 05/06/26.
//

import SwiftUI

struct FamilyAlertsView: View {
    @StateObject private var alertVM = AlertViewModel()
    // ID Family didapatkan dari parent view (FamilyMainView / ViewModel)
    let familyID: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.strideBackground.ignoresSafeArea()
                
                if alertVM.isLoading {
                    ProgressView()
                } else if alertVM.alerts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.strideSecondary)
                        Text("No New Alerts")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        Text("All good! There are no emergency or missed medication alerts at the moment.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.strideTextSecondary)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(alertVM.alerts) { alert in
                                // Karena ini view Family, kita set onResolve jadi nil
                                // (hanya caregiver yang bisa resolve)
                                AlertCard(alert: alert, onResolve: nil)
                            }
                        }
                        .padding(24)
                    }
                }
            }
            .navigationTitle("Alerts & Notifications")
            .onAppear {
                alertVM.fetchAlerts(familyID: familyID)
            }
        }
    }
}
