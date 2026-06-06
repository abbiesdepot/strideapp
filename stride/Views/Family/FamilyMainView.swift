import SwiftUI

struct FamilyMainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var alertVM = FamilyAlertViewModel()

    var body: some View {
        TabView {
            FamilyDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            FamilyAlertCenterView(alertVM: alertVM)
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
                .badge(alertVM.unresolvedCount > 0 ? alertVM.unresolvedCount : 0)

            FamilyProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
        .tint(.strideSecondary)
        .onAppear {
            if let uid = authViewModel.currentUser?.id {
                alertVM.startAlertsListener(userID: uid)
            }
        }
    }
}

#Preview {
    FamilyMainView()
        .environmentObject(AuthViewModel())
}
