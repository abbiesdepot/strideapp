import SwiftUI

struct FallDetectedView: View {
    @EnvironmentObject var sensorManager: WatchSensorManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "#1A2B3C")
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "figure.fall")
                    .font(.system(size: 40))
                    .foregroundColor(.red)

                Text("Fall Detected!")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Alerting your care circle team instantly...")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Button("I'm Okay") {
                    sensorManager.cancelFallAlert()
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}
