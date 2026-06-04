import SwiftUI
import FirebaseFirestore

struct ElderlyDashboardCard: View {
    let profile: ElderlyProfile
    var vitals: VitalSign? = nil
    var medicationCompliance: String? = nil
    var lastActiveText: String? = nil
    
    // Fallback local fetch states
    @State private var localVitals: VitalSign? = nil
    @State private var localCompliance: String = "Loading compliance..."
    @State private var localLastActive: String = "Active today"
    
    var body: some View {
        VStack(spacing: 16) {
            // header
            HStack(alignment: .top) {
                // placeholder profile
                Circle()
                    .fill(Color.strideSecondary.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.strideSecondary)
                            .font(.system(size: 30))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.fullName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.strideTextPrimary)
                    
                    Text("\(profile.age) years old")
                        .font(.system(size: 14))
                        .foregroundColor(.strideTextSecondary)
                    
                    Text(lastActiveText ?? localLastActive)
                        .font(.system(size: 12))
                        .foregroundColor(.strideNeutral)
                }
                .padding(.leading, 8)
                
                Spacer()
            }
            
            // Reusable Status badge with reason
            LiveStatusBadge(status: profile.liveStatus, reason: profile.liveStatusReason)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Stats Grid/Row
            let activeVitals = vitals ?? localVitals
            HStack(alignment: .top) {
                StatItem(icon: "figure.walk", value: "\(profile.stepCount)", label: "Steps")
                Spacer()
                StatItem(icon: "map", value: String(format: "%.1f km", profile.distanceKM), label: "Distance")
                Spacer()
                StatItem(
                    icon: "heart.fill",
                    value: activeVitals != nil ? "\(Int(activeVitals!.heartRate)) bpm" : "-- bpm",
                    label: activeVitals != nil ? "SpO2: \(Int(activeVitals!.spO2))%" : "Vitals"
                )
            }
            
            Divider()
            
            // Med Compliance
            HStack {
                Image(systemName: "pills.fill")
                    .foregroundColor(.strideSecondary)
                Text(medicationCompliance ?? localCompliance)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.strideTextPrimary)
                Spacer()
            }
            .padding(12)
            .background(Color.strideSecondary.opacity(0.1))
            .cornerRadius(12)
            
            // Navigation Actions
            HStack(spacing: 12) {
                NavigationLink(destination: ElderlyDetailView(elderlyID: profile.id ?? "")) {
                    Text("View Details →")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.strideSecondary)
                        .cornerRadius(StrideTheme.cornerRadiusButton)
                }
                
                NavigationLink(destination: WeeklyHealthTrendView(elderlyID: profile.id ?? "")) {
                    Text("View Trends →")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.strideTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.strideNeutral.opacity(0.15))
                        .cornerRadius(StrideTheme.cornerRadiusButton)
                }
            }
        }
        .padding(20)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
        .onAppear {
            fetchLocalDataIfNeeded()
        }
    }
    
    private func fetchLocalDataIfNeeded() {
        let db = Firestore.firestore()
        let targetID = profile.id ?? ""
        guard !targetID.isEmpty else { return }
        
        // 1. Fetch Vitals & Last Active if not passed
        if vitals == nil {
            db.collection("vitalSigns")
                .whereField("elderlyID", isEqualTo: targetID)
                .order(by: "recordedAt", descending: true)
                .limit(to: 1)
                .addSnapshotListener { snapshot, error in
                    if let doc = snapshot?.documents.first {
                        self.localVitals = try? doc.data(as: VitalSign.self)
                        
                        if let lastTime = self.localVitals?.recordedAt {
                            let diff = Int(Date().timeIntervalSince(lastTime))
                            if diff < 60 {
                                self.localLastActive = "Last active just now"
                            } else if diff < 3600 {
                                self.localLastActive = "Last active \(diff / 60) min ago"
                            } else {
                                let hours = diff / 3600
                                if hours < 24 {
                                    self.localLastActive = "Last active \(hours) hr ago"
                                } else {
                                    self.localLastActive = "Last active \(hours / 24) days ago"
                                }
                            }
                        }
                    } else {
                        self.localLastActive = "No activity recorded"
                    }
                }
        }
        
        // 2. Fetch Compliance if not passed
        if medicationCompliance == nil {
            let startOfDay = Calendar.current.startOfDay(for: Date())
            
            db.collection("medications")
                .whereField("elderlyID", isEqualTo: targetID)
                .whereField("isEnabled", isEqualTo: true)
                .addSnapshotListener { medSnapshot, _ in
                    let medCount = medSnapshot?.documents.count ?? 0
                    
                    db.collection("medicationLogs")
                        .whereField("elderlyID", isEqualTo: targetID)
                        .whereField("scheduledTime", isGreaterThanOrEqualTo: startOfDay)
                        .addSnapshotListener { logSnapshot, _ in
                            let logs = logSnapshot?.documents.compactMap { try? $0.data(as: MedicationLog.self) } ?? []
                            let takenCount = logs.filter { $0.status == "taken" }.count
                            let totalCount = max(logs.count, medCount)
                            self.localCompliance = "\(takenCount) of \(totalCount) medications taken"
                        }
                }
        }
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.strideSecondary)
                .font(.system(size: 20))
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.strideTextPrimary)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.strideTextSecondary)
        }
    }
}

#Preview {
    ZStack {
        Color.strideBackground.ignoresSafeArea()
        ElderlyDashboardCard(
            profile: ElderlyProfile(
                id: "123",
                fullName: "Robert Smith",
                age: 78,
                photoURL: nil,
                medicalNotes: "Hypertension",
                familyID: "fam123",
                stepCount: 3200,
                distanceKM: 2.1,
                liveStatus: "green",
                liveStatusReason: "All medications taken",
                createdAt: Date()
            ),
            vitals: nil,
            medicationCompliance: "3 of 4 medications taken",
            lastActiveText: "Last active 12 min ago"
        )
        .padding()
    }
}
