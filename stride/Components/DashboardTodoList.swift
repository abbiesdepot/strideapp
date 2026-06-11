import SwiftUI

struct DashboardTodoList: View {
    @ObservedObject var medVM: MedicationViewModel
    let elderlyID: String
    
    // Split active medications into todo (not taken) and recent (taken today)
    private var todoMedications: [Medication] {
        medVM.medications.filter { med in
            guard med.isEnabled else { return false }
            return !medVM.todayLogs.contains { log in
                log.medicationID == med.id && log.status == "taken"
            }
        }
    }
    
    private var recentMedications: [Medication] {
        medVM.medications.filter { med in
            guard med.isEnabled else { return false }
            return medVM.todayLogs.contains { log in
                log.medicationID == med.id && log.status == "taken"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // TO DO SECTION
            VStack(alignment: .leading, spacing: 12) {
                Text("To Do")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.stridePrimary)
                
                if todoMedications.isEmpty {
                    Text("All tasks completed for today!")
                        .font(.system(size: 14))
                        .foregroundColor(.strideTextSecondary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(todoMedications) { med in
                        todoCard(for: med)
                    }
                }
            }
            
            // RECENT SECTION
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.stridePrimary)
                
                if recentMedications.isEmpty {
                    Text("No tasks completed yet.")
                        .font(.system(size: 14))
                        .foregroundColor(.strideTextSecondary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(recentMedications) { med in
                        recentCard(for: med)
                    }
                }
            }
        }
        .onAppear {
            medVM.fetchMedications(elderlyID: elderlyID)
            medVM.fetchTodayLogs(elderlyID: elderlyID)
        }
    }
    
    @ViewBuilder
    private func todoCard(for medication: Medication) -> some View {
        Button(action: {
            withAnimation {
                medVM.takeMedication(medication: medication)
            }
        }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.stridePrimary)
                    
                    Text("\(medication.scheduleTime) - \(medication.dosage)")
                        .font(.system(size: 14))
                        .foregroundColor(.strideTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "circle")
                    .font(.system(size: 26))
                    .foregroundColor(Color.stridePrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(Color.strideCardWhite)
            .cornerRadius(StrideTheme.cornerRadiusCard)
            .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func recentCard(for medication: Medication) -> some View {
        Button(action: {
            withAnimation {
                if let id = medication.id {
                    medVM.untakeMedication(medicationID: id)
                }
            }
        }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.stridePrimary.opacity(0.6))
                        .strikethrough()
                    
                    Text("\(medication.scheduleTime) - \(medication.dosage)")
                        .font(.system(size: 14))
                        .foregroundColor(.strideTextSecondary.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color.stridePrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(Color.strideCardWhite)
            .cornerRadius(StrideTheme.cornerRadiusCard)
            .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
