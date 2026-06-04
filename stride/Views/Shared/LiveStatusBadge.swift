import SwiftUI

struct LiveStatusBadge: View {
    let status: String  // "green", "yellow", "red"
    let reason: String
    
    var color: Color {
        switch status.lowercased() {
        case "green": return .strideGreen
        case "yellow": return .strideYellow
        case "red": return .strideRed
        default: return .strideNeutral
        }
    }
    
    var text: String {
        switch status.lowercased() {
        case "green": return "Normal"
        case "yellow": return "Warning"
        case "red": return "Emergency"
        default: return "Unknown"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .cornerRadius(12)
            
            if !reason.isEmpty {
                Text(reason)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.strideTextSecondary)
                    .padding(.leading, 2)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        LiveStatusBadge(status: "green", reason: "Good health")
        LiveStatusBadge(status: "yellow", reason: "Missed 1 medication")
        LiveStatusBadge(status: "red", reason: "Fall detected!")
    }
}

