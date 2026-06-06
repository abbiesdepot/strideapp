import SwiftUI

struct OnboardingRoleSelectView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedRole: String? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("STRIDE")
                    .font(.system(size: 28, weight: .black, design: .default))
                    .foregroundColor(.stridePrimary)
                
                Text("Care without distance")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.strideSecondary)
            }
            .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Who are you?")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(.stridePrimary)
                
                Text("Choose your profile to personalize your Stride experience.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.strideTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                RoleCard(
                    icon: "stethoscope",
                    title: "Caregiver",
                    description: "Manage and monitor your patient's health",
                    isSelected: selectedRole == "caregiver"
                ) {
                    selectedRole = "caregiver"
                }
                
                RoleCard(
                    icon: "house.fill",
                    title: "Family",
                    description: "Stay updated on your loved ones' condition",
                    isSelected: selectedRole == "family_member"
                ) {
                    selectedRole = "family_member"
                }
            }
            
            Spacer()
            
            NavigationLink(destination: RegisterView(role: selectedRole ?? "")) {
                Text("CONTINUE")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedRole == nil ? Color.strideNeutral.opacity(0.5) : Color.stridePrimary)
                    .foregroundColor(.white)
                    .cornerRadius(StrideTheme.cornerRadiusButton)
            }
            .disabled(selectedRole == nil)
            
            NavigationLink(destination: LoginView()) {
                Text("Already have an account? Sign in.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.strideSecondary)
            }
        }
        .padding(24)
        .background(Color.strideBackground.ignoresSafeArea())
    }
}

struct RoleCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .strideSecondary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(isSelected ? .white : .stridePrimary)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .strideTextSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }
            }
            .padding(20)
            .background(isSelected ? Color.stridePrimary : Color.strideCardWhite)
            .cornerRadius(StrideTheme.cornerRadiusCard)
            .overlay(
                RoundedRectangle(cornerRadius: StrideTheme.cornerRadiusCard)
                    .stroke(isSelected ? Color.strideTertiary : Color.clear, lineWidth: 2)
            )
            .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingRoleSelectView()
            .environmentObject(AuthViewModel())
    }
}
