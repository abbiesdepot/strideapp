import SwiftUI

struct CaregiverMainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var dashboardVM = CaregiverDashboardViewModel()
    @StateObject private var alertVM = AlertViewModel()
    
    var body: some View {
        TabView {
            CaregiverDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
            
            AlertCenterView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
                .badge(alertVM.unreadCount > 0 ? alertVM.unreadCount : 0)
            
            CaregiverProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
        .tint(.stridePrimary)
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

