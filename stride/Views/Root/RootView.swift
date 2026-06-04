import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                if user.role.lowercased() == "caregiver" {
                    CaregiverMainView()
                        .environmentObject(authViewModel)
                } else {
                    FamilyMainView()
                        .environmentObject(authViewModel)
                }
            } else {
                NavigationStack {
                    OnboardingRoleSelectView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}


#Preview {
    RootView()
}
