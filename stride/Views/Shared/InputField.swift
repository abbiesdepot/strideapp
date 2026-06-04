import SwiftUI

struct InputField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color.strideBackground)
        .cornerRadius(StrideTheme.cornerRadiusButton)
        .overlay(
            RoundedRectangle(cornerRadius: StrideTheme.cornerRadiusButton)
                .stroke(Color.strideNeutral.opacity(0.2), lineWidth: 1)
        )
        .disableAutocorrection(true)
        .font(.system(size: 16, weight: .regular, design: .default))
        .foregroundColor(.strideTextPrimary)
    }
}

#Preview {
    VStack {
        InputField(placeholder: "Full Name", text: .constant(""))
        InputField(placeholder: "Password", text: .constant(""), isSecure: true)
    }
    .padding()
}
