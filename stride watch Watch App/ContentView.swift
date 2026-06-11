import SwiftUI


extension Color {
    init(hex: String) {
        //removes symbols like #
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        //converts hex codes into num
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count { //bit shifting
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

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A2B3C")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 8) {

                        HStack {
                            Text("STRIDE")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#4DA1A9"))
                            Spacer()
                            if sensorManager.demoMode {
                                Text("DEMO")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.yellow)
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal, 8)

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

                        if sensorManager.sensorsActive || sensorManager.demoMode {
                            VStack(spacing: 4) {
                                HStack {
                                    Text("G-Force")
                                        .font(.system(size: 9))
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(String(format: "%.2fg", sensorManager.currentGForce))
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundColor(gForceColor)
                                }
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.white.opacity(0.1))
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(gForceColor)
                                            .frame(width: geo.size.width * min(sensorManager.currentGForce / 5.0, 1.0))
                                            .animation(.linear(duration: 0.1), value: sensorManager.currentGForce)
                                    }
                                }
                                .frame(height: 5)
                            }
                            .padding(.horizontal, 8)
                        } else {
                            Text("Sensors unavailable — use Demo button")
                                .font(.system(size: 9))
                                .foregroundColor(.gray.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }

                        VStack(spacing: 6) {
                            Toggle(isOn: $sensorManager.demoMode) {
                                Text("Demo Mode")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#4DA1A9")))
                            .padding(.horizontal, 8)

                            if sensorManager.demoMode {
                                Text("Simulating fall in progress…")
                                    .font(.system(size: 9))
                                    .foregroundColor(.orange)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                            }
                        }

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
                        .padding(.bottom, 4)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationDestination(isPresented: $sensorManager.isFallDetected) {
                FallDetectedView()
                    .environmentObject(sensorManager)
                    .navigationBarBackButtonHidden(true)
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

    private var gForceColor: Color {
        if sensorManager.currentGForce > 3.0 { return .red }
        if sensorManager.currentGForce > 2.0 { return .orange }
        return Color(hex: "#4DA1A9")
    }
}
