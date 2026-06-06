import SwiftUI

struct LiveStatusBadge: View {
    let status: String
    
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
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                // pulse animation can be added here if needed
                
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 16) {
        LiveStatusBadge(status: "green")
        LiveStatusBadge(status: "yellow")
        LiveStatusBadge(status: "red")
    }
}
