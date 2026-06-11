import SwiftUI

struct AddActivitySheet: View {
    let elderlyID: String
    let activityVM: ActivityViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var frequency = "Once daily"
    @State private var scheduleTime = Date()

    let frequencies = ["Once daily", "Twice daily", "Three times daily", "As needed"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Activity Name (e.g. Shower)", text: $name)
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { Text($0) }
                    }
                }
                Section(header: Text("Schedule")) {
                    DatePicker("Time", selection: $scheduleTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Add Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        let timeString = formatter.string(from: scheduleTime)
                        activityVM.addActivity(
                            elderlyID: elderlyID,
                            name: name,
                            frequency: frequency,
                            scheduleTime: timeString
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
