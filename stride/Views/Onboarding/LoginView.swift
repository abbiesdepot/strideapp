import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome back")
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundColor(.stridePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)
            
            VStack(spacing: 16) {
                InputField(placeholder: "Email", text: $email)
                InputField(placeholder: "Password", text: $password, isSecure: true)
            }
            
            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.strideRed)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                authViewModel.login(email: email, password: password)
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("SIGN IN")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.stridePrimary : Color.strideNeutral.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(StrideTheme.cornerRadiusButton)
            }
            .disabled(!isFormValid || authViewModel.isLoading)
            .padding(.top, 16)
            
            Spacer()
        }
        .padding(24)
        .background(Color.strideBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
