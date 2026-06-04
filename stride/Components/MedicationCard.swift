import SwiftUI

struct MedicationCard: View {
    let medication: Medication
    let onToggle: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 16) {
            // icon
            Circle()
                .fill(Color.strideSecondary.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "pills.fill")
                        .foregroundColor(.strideSecondary)
                        .font(.system(size: 24))
                )
            
            // details buat medicationnyaxa
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.strideTextPrimary)
                
                Text("\(medication.dosage) • \(medication.frequency)")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.strideTextSecondary)
                
                Text(medication.scheduleTime)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.stridePrimary)
            }
            
            Spacer()
            
            // ngetoggle nya
            if let onToggle = onToggle {
                Toggle("", isOn: Binding(
                    get: { medication.isEnabled },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
                .tint(.strideSecondary)
            }
        }
        .padding(16)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
    }
}

#Preview {
    ZStack {
        Color.strideBackground.ignoresSafeArea()
        MedicationCard(medication: Medication(
            id: "1",
            elderlyID: "123",
            name: "Lisinopril",
            dosage: "10mg",
            frequency: "Once daily",
            scheduleTime: "08:00",
            isEnabled: true,
            createdAt: Date()
        ), onToggle: {})
        .padding()
    }
}

#Preview {
    ZStack {
        Color.strideBackground.ignoresSafeArea()
        
        MedicationCard(
            medication: Medication(
                id: "sample_id_1",
                elderlyID: "elder_123",
                name: "Amlodipine Besylate",
                dosage: "5 mg",
                frequency: "Once Daily",
                scheduleTime: "08:00 AM",
                isEnabled: true,
                createdAt: Date()
            ),
            onToggle: {
                print("Semester 4 Console Log: Medication toggle handler clicked!")
            }
        )
        .padding()
    }
}
