import SwiftUI

struct AlertCard: View {
    let alert: Alert
    let onResolve: (() -> Void)?
    
    var severityColor: Color {
        alert.severity.lowercased() == "red" ? .strideRed : .strideYellow
    }
    
    var iconName: String {
        switch alert.type.lowercased() {
        case "sos": return "exclamationmark.triangle.fill"
        case "fall": return "figure.fall"
        case "missed_med": return "pills.fill"
        case "inactivity": return "figure.walk.motion.trianglebadge.exclamationmark"
        case "vital_sign": return "heart.text.square.fill"
        default: return "bell.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // severity bar!!!!!!
            Rectangle()
                .fill(alert.isResolved ? Color.strideNeutral : severityColor)
                .frame(width: 6)
            
            HStack(spacing: 16) {
                // icon
                Circle()
                    .fill((alert.isResolved ? Color.strideNeutral : severityColor).opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: iconName)
                            .foregroundColor(alert.isResolved ? .strideNeutral : severityColor)
                            .font(.system(size: 20))
                    )
                
                // details
                VStack(alignment: .leading, spacing: 4) {
                    Text(alert.message)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(alert.isResolved ? .strideTextSecondary : .strideTextPrimary)
                    
                    Text(alert.triggeredAt, style: .time)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.strideTextSecondary)
                }
                
                Spacer()
                
                if !alert.isResolved, let onResolve = onResolve {
                    Button(action: onResolve) {
                        Text("Resolve")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.stridePrimary)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(16)
        }
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
        .opacity(alert.isResolved ? 0.6 : 1.0)
    }
}

#Preview {
    ZStack {
        Color.strideBackground.ignoresSafeArea()
        VStack(spacing: 16) {
            AlertCard(alert: Alert(
                id: "1",
                elderlyID: "123",
                familyID: "fam1",
                type: "SOS",
                severity: "red",
                message: "SOS Button Pressed",
                isResolved: false,
                triggeredAt: Date()
            ), onResolve: {})
            
            AlertCard(alert: Alert(
                id: "2",
                elderlyID: "123",
                familyID: "fam1",
                type: "missed_med",
                severity: "yellow",
                message: "Missed Lisinopril",
                isResolved: true,
                triggeredAt: Date()
            ), onResolve: {})
        }
        .padding()
    }
}
