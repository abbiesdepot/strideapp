import SwiftUI
import UserNotifications

struct MedicationReminderView: View {
    @EnvironmentObject var sensorManager: WatchSensorManager
    @Environment(\.dismiss) private var dismiss

    var medicationID: String = ""

    @State private var showCheckmark = false

    var body: some View {
        ZStack {
            Color(hex: "#1A2B3C")
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "pill.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "#4DA1A9"))

                Text("Time for your\nmedication")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Button {
                    sensorManager.recordMedicationTaken(medicationID: medicationID)
                    showCheckmark = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                } label: {
                    Text("✓ Taken")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#4DA1A9"))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)

                Button {
                    scheduleReminder()
                    dismiss()
                } label: {
                    Text("Remind in 10 min")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#4DA1A9"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            .padding()

            if showCheckmark {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .animation(.easeInOut(duration: 0.2), value: showCheckmark)
    }

    private func scheduleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take your medication."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 600, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("MedicationReminderView: failed to schedule reminder — \(error.localizedDescription)")
            }
        }
    }
}
