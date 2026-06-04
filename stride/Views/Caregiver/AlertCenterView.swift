import SwiftUI

struct AlertCenterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var dashboardVM = CaregiverDashboardViewModel()
    @StateObject private var alertVM = AlertViewModel()
    
    @State private var selectedFilter = "All"
    let filters = ["All", "SOS", "Missed Med", "Inactivity", "Vital Sign"]
    
    var filteredAlerts: [Alert] {
        if selectedFilter == "All" {
            return alertVM.alerts
        }
        let filterMapping: [String: String] = [
            "SOS": "SOS",
            "Missed Med": "missed_med",
            "Inactivity": "inactivity",
            "Vital Sign": "vital_sign"
        ]
        let targetType = filterMapping[selectedFilter] ?? ""
        return alertVM.alerts.filter { $0.type.lowercased() == targetType.lowercased() }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.strideBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                Button(action: { selectedFilter = filter }) {
                                    Text(filter)
                                        .font(.system(size: 14, weight: .bold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedFilter == filter ? Color.stridePrimary : Color.strideCardWhite)
                                        .foregroundColor(selectedFilter == filter ? .white : .strideTextSecondary)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.strideNeutral.opacity(0.2), lineWidth: selectedFilter == filter ? 0 : 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }
                    
                    if alertVM.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if filteredAlerts.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.strideGreen)
                            Text("No alerts")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.stridePrimary)
                            Text("Everything looks good.")
                                .foregroundColor(.strideTextSecondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredAlerts) { alert in
                                    AlertCard(alert: alert) {
                                        if let id = alert.id {
                                            alertVM.markResolved(alertID: id)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("Alerts")
            .onAppear {
                if let uid = authViewModel.currentUser?.id {
                    dashboardVM.fetchDashboardData(caregiverID: uid)
                }
            }
            .onChange(of: dashboardVM.family?.id) { familyID in
                if let familyID = familyID {
                    alertVM.fetchAlerts(familyID: familyID)
                }
            }
        }
    }
}
