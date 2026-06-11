import SwiftUI

struct ElderlyDashboardCard: View {
    let profile: ElderlyProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header Profile Info
            HStack(alignment: .center, spacing: 14) {
                // Avatar image placeholder
                Circle()
                    .fill(Color.strideTertiary.opacity(0.3))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.stridePrimary)
                            .font(.system(size: 24))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(statusColor(profile.liveStatus))
                            .frame(width: 12, height: 12)
                        
                        Text(profile.fullName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.stridePrimary)
                    }
                    
                    Text(profile.liveStatusReason.isEmpty || profile.liveStatusReason == "Setup complete" ? "Last active 12m ago" : profile.liveStatusReason)
                        .font(.system(size: 14))
                        .foregroundColor(.strideTextSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            // 2x2 Card Grid
            VStack(spacing: 16) {
                // Row 1: Heart Rate (Dark) & Sleep (Light)
                HStack(spacing: 16) {
                    // Heart Rate (Dark)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Heart Rate")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 2) {
                            Text("Current")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                Text(profile.heartRate != nil ? "\(profile.heartRate!)" : "—")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                                Text("BPM")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .frame(height: 160)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.stridePrimary)
                    .cornerRadius(18)
                    
                    // Sleep (Light)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sleep")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        
                        VStack(spacing: 6) {
                            sleepRow(dotColor: Color(hex: "#FF5E5B"), label: "Awake", duration: formatMinutes(profile.sleepAwakeMin))
                            sleepRow(dotColor: Color(hex: "#79D7BE"), label: "REM", duration: formatMinutes(profile.sleepREMMin))
                            sleepRow(dotColor: Color(hex: "#4A90E2"), label: "Core", duration: formatMinutes(profile.sleepCoreMin))
                            sleepRow(dotColor: Color(hex: "#8B5FBF"), label: "Deep", duration: formatMinutes(profile.sleepDeepMin))
                        }
                    }
                    .padding(16)
                    .frame(height: 160)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#F9FAF6"))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.stridePrimary.opacity(0.05), lineWidth: 1)
                    )
                }
                
                // Row 2: Stress (Light) & Steps (Dark)
                HStack(spacing: 16) {
                    // Stress (Light)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stress")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 4) {
                            Text(profile.stressPercentage != nil ? "\(profile.stressPercentage!)%" : "—")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.stridePrimary)
                            Text("Stress")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.stridePrimary.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer()
                    }
                    .padding(16)
                    .frame(height: 160)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#F9FAF6"))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.stridePrimary.opacity(0.05), lineWidth: 1)
                    )
                    
                    // Steps (Dark)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Steps")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.white)
                                .font(.system(size: 26))
                            Text(profile.stepCount != nil ? "\(profile.stepCount!)" : "—")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer()
                        
                        HStack {
                            Text(profile.distanceKM != nil ? String(format: "%.1f KM", profile.distanceKM!) : "—")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("Distance")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(16)
                    .frame(height: 160)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.stridePrimary)
                    .cornerRadius(18)
                }
            }
        }
        .padding(20)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "green":
            return .strideGreen
        case "yellow":
            return .strideYellow
        case "red":
            return .strideRed
        default:
            return .strideNeutral
        }
    }
    
    private func formatMinutes(_ minutes: Int?) -> String {
        guard let mins = minutes else { return "—" }
        let hrs = mins / 60
        let remainingMins = mins % 60
        if hrs > 0 {
            if remainingMins > 0 {
                return "\(hrs) hr \(remainingMins) min"
            } else {
                return "\(hrs) hr"
            }
        } else {
            return "\(remainingMins) min"
        }
    }
    
    private func sleepRow(dotColor: Color, label: String, duration: String) -> some View {
        HStack {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.strideTextSecondary)
            Spacer()
            Text(duration)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.stridePrimary)
        }
    }
}

#Preview {
    ZStack {
        Color.strideBackground.ignoresSafeArea()
        ElderlyDashboardCard(profile: ElderlyProfile(
            id: "123",
            fullName: "Liana Suwono",
            age: 78,
            photoURL: nil,
            medicalNotes: "Hypertension",
            familyID: "fam123",
            stepCount: 3200,
            distanceKM: 1.2,
            heartRate: 68,
            stressPercentage: 67,
            sleepAwakeMin: 6,
            sleepREMMin: 105,
            sleepCoreMin: 288,
            sleepDeepMin: 37,
            liveStatus: "green",
            liveStatusReason: "Last active 12m ago",
            createdAt: Date()
        ))
        .padding()
    }
}
