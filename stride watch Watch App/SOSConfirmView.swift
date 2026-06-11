import SwiftUI

struct SOSConfirmView: View {
    @EnvironmentObject var sensorManager: WatchSensorManager
    @Environment(\.dismiss) private var dismiss

    @State private var progress: Double = 0.0
    @State private var isHolding: Bool = false
    @State private var showingSent: Bool = false
    @State private var timer: Timer? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A2B3C")
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    Text("Send SOS?")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Hold to confirm")
                        .font(.caption2)
                        .foregroundColor(.gray)

                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 6)
                            .frame(width: 70, height: 70)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.red, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 70, height: 70)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.02), value: progress)

                        Text("HOLD")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isHolding {
                                    isHolding = true
                                    startTimer()
                                }
                            }
                            .onEnded { _ in
                                isHolding = false
                                stopTimer()
                                if progress < 1.0 {
                                    progress = 0.0
                                }
                            }
                    )

                    Button("Cancel") {
                        stopTimer()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(.gray)
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $showingSent) {
                SOSSentView()
                    .environmentObject(sensorManager)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            guard isHolding else { return }
            progress += 0.01
            if progress >= 1.0 {
                progress = 1.0
                stopTimer()
                sensorManager.sendSOS()
                showingSent = true
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct SOSSentView: View {
    @EnvironmentObject var sensorManager: WatchSensorManager
    @Environment(\.dismiss) private var dismiss

    @State private var isPulsing: Bool = false

    var body: some View {
        ZStack {
            Color(hex: "#1A2B3C")
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: "#4DA1A9").opacity(0.35))
                    .frame(width: 70, height: 70)
                    .scaleEffect(isPulsing ? 1.25 : 0.85)
                    .overlay(
                        Image(systemName: "sos")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color(hex: "#4DA1A9"))
                    )
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true)
                        ) {
                            isPulsing = true
                        }
                    }

                Text("SOS Alert Sent")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Alerting care team...")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Button("Cancel") {
                    sensorManager.sendSOSCancel()
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.gray)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}
