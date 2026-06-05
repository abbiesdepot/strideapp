import SwiftUI

struct ElderlyDashboardCard: View {
    let profile: ElderlyProfile
    let latestActivity: ActivityLog?
    let latestVitalSign: VitalSign?
    
    var body: some View {
        VStack(spacing: 16) {
            // header
            HStack(alignment: .top) {
                // placeholder profilenya
                Circle()
                    .fill(Color.strideTertiary.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.stridePrimary)
                            .font(.system(size: 30))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.fullName)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.strideTextPrimary)
                    
                    Text("\(profile.age) years old")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.strideTextSecondary)
                }
                .padding(.leading, 8)
                
                Spacer()
                
                LiveStatusBadge(status: profile.liveStatus)
            }
            
            Divider()
            
            // Stats Row
            HStack {
                StatItem(icon: "figure.walk",value: "\(latestActivity?.stepCount ?? profile.stepCount)",label: "Steps today")
                            Spacer()
                            StatItem(icon: "map",value: String(format: "%.1f km",latestActivity?.distanceKM ?? profile.distanceKM),label: "Distance")
                            Spacer()
                            StatItem(icon: "heart.fill",value: latestVitalSign != nil
                                     ? "\(Int(latestVitalSign!.heartRate)) bpm"
                                     : "-- bpm",label: "Heart Rate")
            }
            
            // Reason Text
            if !profile.liveStatusReason.isEmpty {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.strideSecondary)
                    Text(profile.liveStatusReason)
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(.strideTextPrimary)
                    Spacer()
                }
                .padding(12)
                .background(Color.strideSecondary.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
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
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(.strideTextPrimary)
            
            Text(label)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundColor(.strideTextSecondary)
        }
    }
}

#Preview {
    ZStack {
        Color.strideBackground.ignoresSafeArea()
        ElderlyDashboardCard(profile: ElderlyProfile(
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
            latestActivity: ActivityLog(
            id: "a1",
            elderlyID: "123",
            stepCount: 4500,
            distanceKM: 3.8,
            idleMinutes: 20,
            recordedAt: Date()
        ),
        latestVitalSign: VitalSign(
            id: "v1",
            elderlyID: "123",
            heartRate: 74,
            spO2: 98,
            recordedAt: Date()
        ))
        .padding()
    }
}
