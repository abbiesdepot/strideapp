import SwiftUI
import FirebaseFirestore

struct EditActivitySheet: View {
    let activity: CareActivity
    let activityVM: ActivityViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var frequency: String
    @State private var scheduleTime: Date
    @State private var isSaving = false

    let frequencies = ["Once daily", "Twice daily", "Three times daily", "As needed"]

    init(activity: CareActivity, activityVM: ActivityViewModel) {
        self.activity = activity
        self.activityVM = activityVM
        _name = State(initialValue: activity.name)
        _frequency = State(initialValue: activity.frequency)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        _scheduleTime = State(initialValue: formatter.date(from: activity.scheduleTime) ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Activity Name", text: $name)
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { Text($0) }
                    }
                }
                Section(header: Text("Schedule")) {
                    DatePicker("Time", selection: $scheduleTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Edit Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.isEmpty || isSaving)
                }
            }
        }
    }

    private func save() {
        guard let id = activity.id else { return }
        isSaving = true
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: scheduleTime)
        Firestore.firestore().collection("careActivities").document(id).updateData([
            "name": name,
            "frequency": frequency,
            "scheduleTime": timeString
        ]) { _ in
            isSaving = false
            dismiss()
        }
    }
}
