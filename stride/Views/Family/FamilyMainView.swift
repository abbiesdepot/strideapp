import SwiftUI

struct FamilyMainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    // Kita asumsikan kamu bisa menyimpan familyID user di sini atau di ViewModel
    // Untuk keperluan presentasi, kita set dummy string dulu jika belum terhubung
    @AppStorage("userFamilyID") var userFamilyID: String = "fam123"
    
    var body: some View {
        TabView {
            FamilyDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Memanggil halaman Alerts yang baru dibuat
            FamilyAlertsView(familyID: userFamilyID)
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
            
            // Profile Tab
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
