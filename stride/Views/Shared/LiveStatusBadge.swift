import SwiftUI

struct LiveStatusBadge: View {
    let status: String // "green", "yellow", "red"
    
    var statusColor: Color {
        switch status.lowercased() {
        case "green": return Color.green
        case "yellow": return Color.yellow
        case "red": return Color.red
        default: return Color.gray
        }
    }
    
    var statusText: String {
        switch status.lowercased() {
        case "green": return "Normal"
        case "yellow": return "Warning"
        case "red": return "Emergency"
        default: return "Unknown"
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.15))
        .cornerRadius(20)
    }
}
