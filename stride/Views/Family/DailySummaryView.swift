import SwiftUI

struct DailySummaryView: View {
    let profile: ElderlyProfile
    
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
                    
                    LiveStatusBadge(status: profile.liveStatus)
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
                    
                    Text("Medication schedule will appear here.")
                        .foregroundColor(.strideTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .background(Color.strideBackground.ignoresSafeArea())
        .navigationTitle(profile.fullName)
        .navigationBarTitleDisplayMode(.inline)
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
