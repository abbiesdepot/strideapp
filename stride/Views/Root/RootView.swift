import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isLoading {
                ZStack {
                    Color.strideBackground.ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .stridePrimary))
                        .scaleEffect(1.5)
                }
            } else if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                if user.role.lowercased() == "caregiver" {
                    CaregiverMainView()
                } else {
                    // PANGGIL HALAMAN TRANSIT DI SINI
                    FamilyRoutingView()
                }
            } else {
                NavigationStack {
                    OnboardingRoleSelectView()
                }
            }
        }
    }
}
