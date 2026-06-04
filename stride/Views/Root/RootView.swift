import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                if user.role.lowercased() == "caregiver" {
                    CaregiverMainView()
                } else {
                    if authViewModel.isInCareCircle {
                        FamilyMainView()
                    } else {
                        JoinCareCircleView()
                    }
                }
            } else {
                NavigationStack {
                    OnboardingRoleSelectView()
                }
            }
        }
    }
}


#Preview {
    RootView()
}
