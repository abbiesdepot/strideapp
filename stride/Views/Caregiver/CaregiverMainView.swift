import SwiftUI

struct CaregiverMainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            CaregiverDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
            
            MedicationManagerView()
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
            
            PeopleManagementView()
                .tabItem {
                    Label("Care Circle", systemImage: "person.2.fill")
                }
            
            AlertCenterView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
            
            WeeklyHealthTrendView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .tint(.stridePrimary)
    }
}
