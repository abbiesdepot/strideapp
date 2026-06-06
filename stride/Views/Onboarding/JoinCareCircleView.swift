import SwiftUI

struct JoinCareCircleView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var familyVM = FamilyDashboardViewModel()

    /// When non-nil this view is presented as a sheet; on success the closure is called
    /// and the sheet is dismissed by the caller — `authViewModel.isInCareCircle` is NOT set.
    var onJoinSuccess: (() -> Void)? = nil
    
    @State private var inviteCode = ""
    @State private var isSuccess = false
    
    var isFormValid: Bool {
        inviteCode.count == 6
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Circle()
                .fill(Color.strideSecondary.opacity(0.15))
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.strideSecondary)
                        .font(.system(size: 50))
                )
            
            VStack(spacing: 8) {
                Text("Connect to your family")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(.stridePrimary)
                
                Text("Join a family to monitor your loved one's health and stay updated together.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.strideTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("INVITE CODE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.strideTextSecondary)
                
                TextField("X X X X X X", text: $inviteCode)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.strideBackground)
                    .cornerRadius(StrideTheme.cornerRadiusButton)
                    .overlay(
                        RoundedRectangle(cornerRadius: StrideTheme.cornerRadiusButton)
                            .stroke(Color.strideNeutral.opacity(0.2), lineWidth: 1)
                    )
                    .onChange(of: inviteCode) { newValue in
                        if newValue.count > 6 {
                            inviteCode = String(newValue.prefix(6))
                        }
                    }
                
                Text("Ask your caregiver for the invite code.")
                    .font(.system(size: 14))
                    .foregroundColor(.strideTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 24)
            
            if let error = familyVM.errorMessage {
                Text(error)
                    .foregroundColor(.strideRed)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                if let uid = authViewModel.currentUser?.id {
                    familyVM.joinCareCircle(inviteCode: inviteCode, userID: uid) { success, error in
                        if success {
                            if let onJoinSuccess {
                                // sheet mode: let the caller handle dismissal and refresh
                                onJoinSuccess()
                            } else {
                                authViewModel.isInCareCircle = true
                                isSuccess = true
                            }
                        }
                    }
                }
            }) {
                HStack {
                    if familyVM.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "link")
                        Text("Join family")
                    }
                }
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.stridePrimary : Color.strideNeutral.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(StrideTheme.cornerRadiusButton)
            }
            .disabled(!isFormValid || familyVM.isLoading)
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(Color.strideCardWhite.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.strideRed)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .navigationDestination(isPresented: $isSuccess) {
            FamilyMainView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        JoinCareCircleView()
            .environmentObject(AuthViewModel())
    }
}
