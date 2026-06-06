import SwiftUI


struct FamilyAlertCenterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var alertVM: FamilyAlertViewModel

    @State private var selectedFilter: AlertFilter = .all

    var body: some View {
        NavigationStack {
            ZStack {
                Color.strideBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    filterChipsRow
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                    Divider()

                    if alertVM.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if filteredAlerts.isEmpty {
                        emptyState
                    } else {
                        alertList
                    }
                }
            }
            .navigationTitle("Alerts")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if let uid = authViewModel.currentUser?.id {
                    alertVM.markAllAsSeen(userID: uid)
                }
            }
            .onChange(of: alertVM.alerts.count) { _ in
                if let uid = authViewModel.currentUser?.id {
                    alertVM.markAllAsSeen(userID: uid)
                }
            }
        }
    }

    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AlertFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.label,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
        }
    }

    private var alertList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredAlerts) { alert in
                    FamilyAlertCard(alert: alert)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.strideTertiary)
            Text("No alerts — everything looks good")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.stridePrimary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var filteredAlerts: [Alert] {
        guard selectedFilter != .all else { return alertVM.alerts }
        return alertVM.alerts.filter { $0.type == selectedFilter.typeValue }
    }
}

enum AlertFilter: CaseIterable {
    case all, sos, fall, missedMed, inactivity

    var label: String {
        switch self {
        case .all:        return "All"
        case .sos:        return "SOS"
        case .fall:       return "Fall"
        case .missedMed:  return "Missed Med"
        case .inactivity: return "Inactivity"
        }
    }

    var typeValue: String {
        switch self {
        case .all:        return ""
        case .sos:        return "SOS"
        case .fall:       return "fall"
        case .missedMed:  return "missed_med"
        case .inactivity: return "inactivity"
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .stridePrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.strideSecondary : Color.strideCardWhite)
                .cornerRadius(20)
                .shadow(color: StrideTheme.shadowColor, radius: 2, x: 0, y: 1)
        }
    }
}

struct FamilyAlertCard: View {
    let alert: Alert

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(severityColor)
                .frame(width: 4)
                .cornerRadius(2)

            HStack(spacing: 14) {
                Image(systemName: typeIcon)
                    .font(.system(size: 24))
                    .foregroundColor(severityColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(alert.message)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.stridePrimary)
                        .lineLimit(2)

                    Text(alert.triggeredAt, style: .relative)
                        .font(.system(size: 12))
                        .foregroundColor(.strideTextSecondary)
                }

                Spacer()

                if !alert.isResolved {
                    Circle()
                        .fill(severityColor)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
    }

    private var severityColor: Color {
        switch alert.severity {
        case "red":    return .strideRed
        case "yellow": return .strideYellow
        default:       return .strideSecondary
        }
    }

    private var typeIcon: String {
        switch alert.type {
        case "SOS":        return "sos.circle.fill"
        case "fall":       return "figure.fall"
        case "missed_med": return "pills.fill"
        case "inactivity": return "moon.zzz.fill"
        default:           return "exclamationmark.triangle.fill"
        }
    }
}
