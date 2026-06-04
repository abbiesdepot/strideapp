import SwiftUI

struct FamilyMainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            FamilyDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Reusing Caregiver AlertCenterView since logic is basically the same,
            // we just need to disable the resolve button for family members.
            // But since the alertVM logic needs the familyID, we can adapt it or create a specific one.
            // For now, let's just show an empty placeholder or basic view.
            Text("Alerts")
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
            
            VStack {
                Text(authViewModel.currentUser?.fullName ?? "Family Member")
                    .font(.title)
                Text(authViewModel.currentUser?.email ?? "")
                    .foregroundColor(.strideTextSecondary)
                
                Button("Log Out") {
                    authViewModel.logout()
                }
                .foregroundColor(.strideRed)
                .padding(.top, 20)
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle.fill")
            }
        }
        .tint(.stridePrimary)
    }
}

#Preview {
    FamilyMainView()
        .environmentObject(AuthViewModel())
}
