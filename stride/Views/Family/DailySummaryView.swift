import SwiftUI
import FirebaseFirestore

struct DailySummaryView: View {
    let profile: ElderlyProfile
    
    @StateObject private var medVM = MedicationViewModel()
    @State private var todayLogs: [MedicationLog] = []
    @State private var logsListener: ListenerRegistration?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top section
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.strideTertiary.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(Image(systemName: "person.fill").font(.system(size: 40)).foregroundColor(.stridePrimary))
                    
                    Text(profile.fullName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.stridePrimary)
                    
                    LiveStatusBadge(status: profile.liveStatus, reason: profile.liveStatusReason)
                }
                .padding(.top, 20)
                
                // Stat Cards
                HStack(spacing: 16) {
                    MiniStatCard(title: "Steps", value: "\(profile.stepCount)", icon: "figure.walk")
                    MiniStatCard(title: "Distance", value: String(format: "%.1f km", profile.distanceKM), icon: "map")
                }
                .padding(.horizontal, 24)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Schedule")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.stridePrimary)
                    
                    if medVM.medications.isEmpty {
                        Text("No medications scheduled.")
                            .font(.system(size: 14))
                            .foregroundColor(.strideTextSecondary)
                    } else {
                        ForEach(medVM.medications) { medication in
                            let log = todayLogs.first(where: { $0.medicationID == medication.id })
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(medication.name)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.strideTextPrimary)
                                    Text(medication.dosage)
                                        .font(.system(size: 13))
                                        .foregroundColor(.strideTextSecondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(medication.scheduleTime)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.strideTextSecondary)
                                    
                                    if let log = log {
                                        if log.status.lowercased() == "taken" {
                                            Text("taken ✓")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.strideGreen)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.strideGreen.opacity(0.15))
                                                .cornerRadius(6)
                                        } else {
                                            Text("missed ✗")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.strideRed)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.strideRed.opacity(0.15))
                                                .cornerRadius(6)
                                        }
                                    } else {
                                        Text("pending")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.strideNeutral)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.strideNeutral.opacity(0.15))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.strideCardWhite)
                            .cornerRadius(12)
                            .shadow(color: StrideTheme.shadowColor, radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .background(Color.strideBackground.ignoresSafeArea())
        .navigationTitle(profile.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            medVM.fetchMedications(elderlyID: profile.id ?? "")
            listenToTodayLogs(elderlyID: profile.id ?? "")
        }
        .onDisappear {
            logsListener?.remove()
        }
    }
    
    func listenToTodayLogs(elderlyID: String) {
        let db = Firestore.firestore()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        logsListener?.remove()
        logsListener = db.collection("medicationLogs")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .whereField("scheduledTime", isGreaterThanOrEqualTo: startOfDay)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.todayLogs = documents.compactMap { try? $0.data(as: MedicationLog.self) }
            }
    }
}

struct MiniStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.strideSecondary)
                .font(.system(size: 24))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.stridePrimary)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.strideTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
    }
}
