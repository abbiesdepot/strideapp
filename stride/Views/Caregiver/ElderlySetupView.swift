import SwiftUI

struct ElderlySetupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: CaregiverDashboardViewModel
    
    @State private var step = 1
    
    @State private var fullName = ""
    @State private var ageString = ""
    @State private var heightString = ""
    @State private var weightString = ""
    @State private var bloodType = "A"
    @State private var medicalNotes = ""
    @State private var notes = ""
    
    let bloodTypes = ["A", "B", "AB", "O", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    
    var isFormValid: Bool {
        !fullName.isEmpty && Int(ageString) != nil
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack {
                    ForEach(1...3, id: \.self) { i in
                        Circle()
                            .fill(i <= step ? Color.stridePrimary : Color.strideNeutral.opacity(0.3))
                            .frame(width: 10, height: 10)
                        if i < 3 {
                            Rectangle()
                                .fill(i < step ? Color.stridePrimary : Color.strideNeutral.opacity(0.3))
                                .frame(height: 2)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                if step == 1 {
                    step1View
                } else if step == 2 {
                    step2View
                } else {
                    step3View
                }
                
                Spacer()
            }
            .padding(24)
            .background(Color.strideBackground.ignoresSafeArea())
            .navigationTitle("Setup Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    var step1View: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Elderly Profile")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.stridePrimary)
                
                VStack(spacing: 16) {
                    InputField(placeholder: "Full Name", text: $fullName)
                    
                    HStack(spacing: 16) {
                        InputField(placeholder: "Age", text: $ageString)
                        
                        Menu {
                            ForEach(bloodTypes, id: \.self) { type in
                                Button(type) {
                                    bloodType = type
                                }
                            }
                        } label: {
                            HStack {
                                Text("Blood: \(bloodType)")
                                    .foregroundColor(.strideTextPrimary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(Color.strideNeutral)
                            }
                            .padding()
                            // Memberi height agar sejajar dengan InputField bawaan
                            .frame(minHeight: 50)
                            .background(Color.strideBackground)
                            .cornerRadius(StrideTheme.cornerRadiusButton)
                            .overlay(
                                RoundedRectangle(cornerRadius: StrideTheme.cornerRadiusButton)
                                    .stroke(Color.strideNeutral.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    
                    HStack(spacing: 16) {
                        InputField(placeholder: "Height (cm)", text: $heightString)
                        InputField(placeholder: "Weight (kg)", text: $weightString)
                    }
                    
                    TextField("Medical Notes (Optional)", text: $medicalNotes, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                        .padding()
                        .background(Color.strideBackground)
                        .cornerRadius(StrideTheme.cornerRadiusButton)
                        .overlay(
                            RoundedRectangle(cornerRadius: StrideTheme.cornerRadiusButton)
                                .stroke(Color.strideNeutral.opacity(0.2), lineWidth: 1)
                        )
                        
                    TextField("General Notes (Optional)", text: $notes, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                        .padding()
                        .background(Color.strideBackground)
                        .cornerRadius(StrideTheme.cornerRadiusButton)
                        .overlay(
                            RoundedRectangle(cornerRadius: StrideTheme.cornerRadiusButton)
                                .stroke(Color.strideNeutral.opacity(0.2), lineWidth: 1)
                        )
                }
                
                Button(action: {
                    withAnimation { step = 2 }
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.stridePrimary : Color.strideNeutral.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(StrideTheme.cornerRadiusButton)
                }
                .disabled(!isFormValid)
                .padding(.top, 16)
            }
            .padding(.bottom, 20)
        }
    }
    
    var step2View: some View {
        VStack(spacing: 32) {
            Text("Watch Pairing")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.stridePrimary)
            
            Image(systemName: "applewatch")
                .font(.system(size: 80))
                .foregroundColor(.strideSecondary)
            
            Text("Apple Watch detected ✓")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.strideGreen)
            
            Text("Stride is now active on this Watch")
                .font(.system(size: 14))
                .foregroundColor(.strideTextSecondary)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.strideRed)
                    .font(.system(size: 14))
            }
            
            Button(action: {
                guard let uid = authViewModel.currentUser?.id, let age = Int(ageString) else { return }
                let parsedHeight = Double(heightString)
                let parsedWeight = Double(weightString)
                
                viewModel.createElderlyProfile(
                    caregiverID: uid,
                    fullName: fullName,
                    age: age,
                    height: parsedHeight,
                    weight: parsedWeight,
                    bloodType: bloodType,
                    medicalNotes: medicalNotes,
                    notes: notes
                ) { success in
                    if success {
                        withAnimation { step = 3 }
                    }
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Confirm & Create")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.stridePrimary)
                .foregroundColor(.white)
                .cornerRadius(StrideTheme.cornerRadiusButton)
            }
            .disabled(viewModel.isLoading)
        }
    }
    
    var step3View: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.strideGreen)
            
            Text("Setup Complete")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.stridePrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                    Text("Profile Created")
                }
                HStack {
                    Image(systemName: "applewatch")
                    Text("Watch Connected")
                }
                HStack {
                    Image(systemName: "house.fill")
                    Text("Family Active")
                }
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.strideTextPrimary)
            
            Button(action: {
                dismiss()
            }) {
                Text("Go to Dashboard")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.stridePrimary)
                    .foregroundColor(.white)
                    .cornerRadius(StrideTheme.cornerRadiusButton)
            }
        }
    }
}
