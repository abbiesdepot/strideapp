import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let role: String
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    
    var isFormValid: Bool {
        !fullName.isEmpty && !email.isEmpty && !phone.isEmpty && !password.isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Create Account")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(.stridePrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    InputField(placeholder: "Full Name", text: $fullName)
                    InputField(placeholder: "Email", text: $email)
                    InputField(placeholder: "Phone Number", text: $phone)
                    InputField(placeholder: "Password", text: $password, isSecure: true)
                }
                
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.strideRed)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    authViewModel.register(fullName: fullName, email: email, phone: phone, role: role, password: password)
                }) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("CREATE ACCOUNT")
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
        }
        .background(Color.strideBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RegisterView(role: "caregiver")
            .environmentObject(AuthViewModel())
    }
}
