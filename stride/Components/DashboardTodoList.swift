import SwiftUI

struct UnifiedTask: Identifiable {
    let id: String
    let name: String
    let scheduleTime: String
    let subtitle: String
    let isMedication: Bool
    let medication: Medication?
    let activity: CareActivity?
}

struct DashboardTodoList: View {
    @ObservedObject var medVM: MedicationViewModel
    @ObservedObject var activityVM: ActivityViewModel
    let elderlyID: String
    
    private var todoTasks: [UnifiedTask] {
        let medTasks = medVM.medications.filter { med in
            guard med.isEnabled else { return false }
            return !medVM.todayLogs.contains { log in
                log.medicationID == med.id && log.status == "taken"
            }
        }.map { med in
            UnifiedTask(
                id: med.id ?? UUID().uuidString,
                name: med.name,
                scheduleTime: med.scheduleTime,
                subtitle: "\(med.dosage) • \(med.frequency)",
                isMedication: true,
                medication: med,
                activity: nil
            )
        }
        
        let actTasks = activityVM.activities.filter { act in
            guard act.isEnabled else { return false }
            return !activityVM.todayLogs.contains { log in
                log.activityID == act.id && log.status == "done"
            }
        }.map { act in
            UnifiedTask(
                id: act.id ?? UUID().uuidString,
                name: act.name,
                scheduleTime: act.scheduleTime,
                subtitle: act.frequency,
                isMedication: false,
                medication: nil,
                activity: act
            )
        }
        
        return (medTasks + actTasks).sorted { $0.scheduleTime < $1.scheduleTime }
    }
    
    private var recentTasks: [UnifiedTask] {
        let medTasks = medVM.medications.filter { med in
            guard med.isEnabled else { return false }
            return medVM.todayLogs.contains { log in
                log.medicationID == med.id && log.status == "taken"
            }
        }.map { med in
            UnifiedTask(
                id: med.id ?? UUID().uuidString,
                name: med.name,
                scheduleTime: med.scheduleTime,
                subtitle: "\(med.dosage) • \(med.frequency)",
                isMedication: true,
                medication: med,
                activity: nil
            )
        }
        
        let actTasks = activityVM.activities.filter { act in
            guard act.isEnabled else { return false }
            return activityVM.todayLogs.contains { log in
                log.activityID == act.id && log.status == "done"
            }
        }.map { act in
            UnifiedTask(
                id: act.id ?? UUID().uuidString,
                name: act.name,
                scheduleTime: act.scheduleTime,
                subtitle: act.frequency,
                isMedication: false,
                medication: nil,
                activity: act
            )
        }
        
        return (medTasks + actTasks).sorted { $0.scheduleTime < $1.scheduleTime }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // TO DO SECTION
            VStack(alignment: .leading, spacing: 12) {
                Text("To Do")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.stridePrimary)
                
                if todoTasks.isEmpty {
                    Text("All tasks completed for today!")
                        .font(.system(size: 14))
                        .foregroundColor(.strideTextSecondary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(todoTasks) { task in
                        todoCard(for: task)
                    }
                }
            }
            
            // RECENT SECTION
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.stridePrimary)
                
                if recentTasks.isEmpty {
                    Text("No tasks completed yet.")
                        .font(.system(size: 14))
                        .foregroundColor(.strideTextSecondary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(recentTasks) { task in
                        recentCard(for: task)
                    }
                }
            }
        }
        .onAppear {
            medVM.fetchMedications(elderlyID: elderlyID)
            medVM.fetchTodayLogs(elderlyID: elderlyID)
            activityVM.fetchActivities(elderlyID: elderlyID)
            activityVM.fetchTodayLogs(elderlyID: elderlyID)
        }
    }
    
    @ViewBuilder
    private func todoCard(for task: UnifiedTask) -> some View {
        Button(action: {
            withAnimation {
                if task.isMedication {
                    if let med = task.medication {
                        medVM.takeMedication(medication: med)
                    }
                } else {
                    if let act = task.activity {
                        activityVM.takeActivity(activity: act)
                    }
                }
            }
        }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.stridePrimary)
                    
                    Text("\(task.scheduleTime) - \(task.subtitle)")
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
    private func recentCard(for task: UnifiedTask) -> some View {
        Button(action: {
            withAnimation {
                if task.isMedication {
                    if let medID = task.medication?.id {
                        medVM.untakeMedication(medicationID: medID)
                    }
                } else {
                    if let actID = task.activity?.id {
                        activityVM.untakeActivity(activityID: actID)
                    }
                }
            }
        }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.stridePrimary.opacity(0.6))
                        .strikethrough()
                    
                    Text("\(task.scheduleTime) - \(task.subtitle)")
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
