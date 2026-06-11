import SwiftUI

struct AddMedicationSheet: View {
    let elderlyID: String
    let medVM: MedicationViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var dosage = ""
    @State private var frequency = "Once daily"
    @State private var scheduleTime = Date()

    let frequencies = ["Once daily", "Twice daily", "Three times daily", "As needed"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage (e.g., 10mg)", text: $dosage)
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { Text($0) }
                    }
                }
                Section(header: Text("Schedule")) {
                    DatePicker("Time", selection: $scheduleTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Add Medication")
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
                        medVM.addMedication(
                            elderlyID: elderlyID,
                            name: name,
                            dosage: dosage,
                            frequency: frequency,
                            scheduleTime: timeString
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }
}
