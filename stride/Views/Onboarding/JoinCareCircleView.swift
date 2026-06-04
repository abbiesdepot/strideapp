import SwiftUI

struct JoinCareCircleView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var familyVM = FamilyDashboardViewModel()
    
    @State private var inviteCode = ""
    @State private var inlineError: String? = nil
    
    var isFormValid: Bool {
        inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).count == 6
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Stride Logo at top
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.strideSecondary)
                Text("STRIDE")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.stridePrimary)
            }
            .padding(.bottom, 20)
            
            VStack(spacing: 8) {
                Text("Join a Care Circle")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.stridePrimary)
                
                Text("Enter the invite code from your caregiver to get started")
                    .font(.system(size: 15))
                    .foregroundColor(.strideTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Large styled text input: 6 characters, auto uppercase, letter spacing wide, centered
            VStack(spacing: 12) {
                TextField("------", text: $inviteCode)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .tracking(10)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(Color.strideBackground)
                    .cornerRadius(StrideTheme.cornerRadiusButton)
                    .overlay(
                        RoundedRectangle(cornerRadius: StrideTheme.cornerRadiusButton)
                            .stroke(inlineError != nil ? Color.strideRed : Color.strideNeutral.opacity(0.3), lineWidth: 1.5)
                    )
                    .onChange(of: inviteCode) { newValue in
                        // Auto uppercase and restrict to 6 characters
                        let filtered = newValue.uppercased().filter { "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".contains($0) }
                        if filtered.count > 6 {
                            inviteCode = String(filtered.prefix(6))
                        } else {
                            inviteCode = filtered
                        }
                        inlineError = nil
                    }
                
                if let error = inlineError {
                    Text(error)
                        .foregroundColor(.strideRed)
                        .font(.system(size: 14, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 32)
            
            // Teal Join Family Button
            Button(action: {
                guard let uid = authViewModel.currentUser?.id else { return }
                inlineError = nil
                
                familyVM.joinCareCircle(inviteCode: inviteCode, userID: uid) { success, error in
                    if success {
                        // Mark in environment that we successfully joined
                        authViewModel.isInCareCircle = true
                    } else {
                        inlineError = "Invalid code. Ask your caregiver to check the invite code."
                    }
                }
            }) {
                HStack {
                    if familyVM.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Join Family")
                    }
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.strideSecondary : Color.strideNeutral.opacity(0.4))
                .cornerRadius(StrideTheme.cornerRadiusButton)
            }
            .disabled(!isFormValid || familyVM.isLoading)
            .padding(.horizontal, 32)
            
            Button("Log Out") {
                authViewModel.logout()
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.strideTextSecondary)
            .padding(.top, 8)
            
            Spacer()
        }
        .background(Color.strideCardWhite.ignoresSafeArea())
        .animation(.default, value: inlineError)
    }
}

#Preview {
    JoinCareCircleView()
        .environmentObject(AuthViewModel())
}
