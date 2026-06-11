import SwiftUI

struct FallDetectedView: View {
    @EnvironmentObject var sensorManager: WatchSensorManager
    @Environment(\.dismiss) private var dismiss

    @State private var isPulsing: Bool = false
    @State private var iconScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            (sensorManager.fallCountdown <= 5 ? Color.red.opacity(0.15) : Color(hex: "#1A2B3C"))
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: sensorManager.fallCountdown <= 5)

            VStack(spacing: 10) {

                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .scaleEffect(isPulsing ? 1.3 : 0.9)
                        .animation(
                            .easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                            value: isPulsing
                        )

                    Image(systemName: "figure.fall")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.red)
                        .scaleEffect(iconScale)
                }
                .onAppear {
                    isPulsing = true
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        iconScale = 1.2
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            iconScale = 1.0
                        }
                    }
                }

                Text("Fall Detected!")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Text("Alerting your care circle...")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: CGFloat(sensorManager.fallCountdown) / 15.0)
                        .stroke(
                            sensorManager.fallCountdown <= 5 ? Color.red : Color.orange,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: sensorManager.fallCountdown)

                    Text("\(sensorManager.fallCountdown)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(sensorManager.fallCountdown <= 5 ? .red : .white)
                }

                Text("seconds to confirm")
                    .font(.system(size: 9))
                    .foregroundColor(.gray.opacity(0.7))

                Button {
                    sensorManager.cancelFallAlert()
                    dismiss()
                } label: {
                    Text(sensorManager.fallCountdown > 0 ? "I'm Okay" : "Alert Sent")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(sensorManager.fallCountdown > 0 ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(sensorManager.fallCountdown > 0 ? Color.green : Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .disabled(sensorManager.fallCountdown == 0)
                .animation(.easeInOut(duration: 0.3), value: sensorManager.fallCountdown == 0)
            }
            .padding(.vertical, 8)
        }
        .navigationBarBackButtonHidden(true)
    }
}
