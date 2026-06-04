import SwiftUI

struct FamilyAlertCenterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var alertVM = FamilyAlertViewModel()
    
    @State private var selectedFilter = "All"
    let filters = ["All", "SOS", "Missed Med", "Inactivity"]
    
    var filteredAlerts: [Alert] {
        if selectedFilter == "All" {
            return alertVM.alerts
        }
        let filterMapping: [String: String] = [
            "SOS": "sos",
            "Missed Med": "missed_med",
            "Inactivity": "inactivity"
        ]
        let targetType = filterMapping[selectedFilter] ?? ""
        return alertVM.alerts.filter { $0.type.lowercased() == targetType }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.strideBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Chips Scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                Button(action: { selectedFilter = filter }) {
                                    Text(filter)
                                        .font(.system(size: 14, weight: .bold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedFilter == filter ? Color.stridePrimary : Color.strideCardWhite)
                                        .foregroundColor(selectedFilter == filter ? .white : .strideTextSecondary)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.strideNeutral.opacity(0.2), lineWidth: selectedFilter == filter ? 0 : 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }
                    
                    if alertVM.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if filteredAlerts.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.strideGreen)
                            
                            Text("No alerts — everything looks good")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.stridePrimary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Button(action: {
                                if let uid = authViewModel.currentUser?.id {
                                    alertVM.startAlertsListener(userID: uid)
                                }
                            }) {
                                Text("Refresh Alerts")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.stridePrimary)
                                    .cornerRadius(StrideTheme.cornerRadiusButton)
                            }
                            .padding(.top, 8)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredAlerts) { alert in
                                    let elderlyName = alertVM.elderlyNames[alert.elderlyID] ?? "Elderly Profile"
                                    FamilyAlertCard(alert: alert, elderlyName: elderlyName)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("Alerts")
            .onAppear {
                if let uid = authViewModel.currentUser?.id {
                    alertVM.startAlertsListener(userID: uid)
                }
            }
            .onDisappear {
                if let uid = authViewModel.currentUser?.id {
                    alertVM.markAllAsSeen(userID: uid)
                }
            }
            .onChange(of: alertVM.alerts.count) { _ in
                // Also mark as seen when new alerts arrive while on screen
                if let uid = authViewModel.currentUser?.id {
                    alertVM.markAllAsSeen(userID: uid)
                }
            }
        }
    }
}

struct FamilyAlertCard: View {
    let alert: Alert
    let elderlyName: String
    
    var severityColor: Color {
        alert.severity.lowercased() == "red" ? .strideRed : .strideYellow
    }
    
    var iconName: String {
        switch alert.type.lowercased() {
        case "sos": return "sos.circle.fill"
        case "fall": return "figure.fall"
        case "missed_med": return "pills.fill"
        case "inactivity": return "moon.zzz.fill"
        default: return "bell.fill"
        }
    }
    
    var iconColor: Color {
        let type = alert.type.lowercased()
        if type == "sos" || type == "fall" {
            return .strideRed
        } else {
            return .strideYellow
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Colored Border
            Rectangle()
                .fill(severityColor)
                .frame(width: 6)
            
            // Icon
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.15))
                .clipShape(Circle())
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(elderlyName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.strideTextPrimary)
                    Spacer()
                    Text(formatAlertTime(alert.triggeredAt))
                        .font(.system(size: 11))
                        .foregroundColor(.strideTextSecondary)
                }
                
                Text(alert.message)
                    .font(.system(size: 14))
                    .foregroundColor(.strideTextPrimary)
                    .lineLimit(2)
            }
            .padding(.trailing, 16)
        }
        .frame(height: 76)
        .background(Color.strideCardWhite)
        .cornerRadius(8)
        .shadow(color: StrideTheme.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    private func formatAlertTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let timeStr = formatter.string(from: date)
        
        if calendar.isDateInToday(date) {
            return "Today \(timeStr)"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday \(timeStr)"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, hh:mm a"
            return dateFormatter.string(from: date)
        }
    }
}

#Preview {
    FamilyAlertCenterView()
        .environmentObject(AuthViewModel())
}
