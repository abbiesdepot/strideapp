//import SwiftUI
//
//struct DailySummaryView: View {
//    let profile: ElderlyProfile
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 24) {
//                // Top section
//                VStack(spacing: 12) {
//                    Circle()
//                        .fill(Color.strideTertiary.opacity(0.3))
//                        .frame(width: 80, height: 80)
//                        .overlay(Image(systemName: "person.fill").font(.system(size: 40)).foregroundColor(.stridePrimary))
//                    
//                    Text(profile.fullName)
//                        .font(.system(size: 24, weight: .bold))
//                        .foregroundColor(.stridePrimary)
//                    
//                    LiveStatusBadge(status: profile.liveStatus)
//                }
//                .padding(.top, 20)
//                
//                // Stat Cards
//                HStack(spacing: 16) {
//                    MiniStatCard(title: "Steps", value: "\(profile.stepCount)", icon: "figure.walk")
//                    MiniStatCard(title: "Distance", value: String(format: "%.1f km", profile.distanceKM), icon: "map")
//                }
//                .padding(.horizontal, 24)
//                
//                // Today's Schedule Section
//                VStack(alignment: .leading, spacing: 16) {
//                    Text("Today's Schedule")
//                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(.stridePrimary)
//                    
//                    // Mock Data untuk keperluan presentasi UI
//                    VStack(spacing: 12) {
//                        MedicationRow(medName: "Amlodipine (Darah Tinggi)", time: "08:00 AM", status: "taken")
//                        MedicationRow(medName: "Metformin (Gula Darah)", time: "01:00 PM", status: "missed")
//                        MedicationRow(medName: "Lisinopril", time: "08:00 PM", status: "upcoming")
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 24)
//                
//                Spacer()
//            }
//        }
//        .background(Color.strideBackground.ignoresSafeArea())
//        .navigationTitle(profile.fullName)
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// Sub-view untuk menampilkan baris obat
//struct MedicationRow: View {
//    let medName: String
//    let time: String
//    let status: String // "taken", "missed", "upcoming"
//    
//    var statusIcon: String {
//        switch status {
//        case "taken": return "checkmark.circle.fill"
//        case "missed": return "xmark.circle.fill"
//        default: return "clock.fill"
//        }
//    }
//    
//    var statusColor: Color {
//        switch status {
//        case "taken": return .green
//        case "missed": return .red
//        default: return .strideSecondary
//        }
//    }
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text(medName)
//                    .font(.system(size: 16, weight: .bold))
//                    .foregroundColor(.strideTextPrimary)
//                Text(time)
//                    .font(.system(size: 14))
//                    .foregroundColor(.strideTextSecondary)
//            }
//            
//            Spacer()
//            
//            Image(systemName: statusIcon)
//                .foregroundColor(statusColor)
//                .font(.system(size: 24))
//        }
//        .padding(16)
//        .background(Color.strideCardWhite)
//        .cornerRadius(StrideTheme.cornerRadiusCard)
//        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
//    }
//}
