import SwiftUI


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    @StateObject private var sensorManager = WatchSensorManager()

    @State private var showSOS = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A2B3C")
                    .ignoresSafeArea()

                VStack(spacing: 8) {
                    Text("STRIDE")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4DA1A9"))

                    HStack(spacing: 6) {
                        Circle()
                            .fill(statusColor(for: sensorManager.liveStatus))
                            .frame(width: 10, height: 10)

                        Text(sensorManager.liveStatusReason.isEmpty ? "All good" : sensorManager.liveStatusReason)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }

                    Divider()
                        .background(Color.gray.opacity(0.4))
                        .padding(.horizontal)

                    VStack(spacing: 2) {
                        Text("\(sensorManager.stepCount)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("steps")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }

                    Text(String(format: "%.2f km", sensorManager.distanceKM))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))

                    Spacer(minLength: 4)

                    NavigationLink(destination: SOSConfirmView()
                        .environmentObject(sensorManager)) {
                        Text("SOS")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                }
                .padding(.vertical, 8)
            }
            .navigationDestination(isPresented: $sensorManager.isFallDetected) {
                FallDetectedView()
                    .environmentObject(sensorManager)
                    .navigationBarBackButtonHidden(true)
            }
            .onLongPressGesture {
                sensorManager.triggerFallSequence()
            }
            .onAppear {
                sensorManager.setupSensorMonitoring()
            }
        }
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "red":    return .red
        case "yellow": return .yellow
        default:       return .green
        }
    }
}
