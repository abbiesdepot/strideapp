import SwiftUI
import FirebaseFirestore

struct EditMedicationSheet: View {
    let medication: Medication
    let medVM: MedicationViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var dosage: String
    @State private var frequency: String
    @State private var scheduleTime: Date
    @State private var isSaving = false

    let frequencies = ["Once daily", "Twice daily", "Three times daily", "As needed"]

    init(medication: Medication, medVM: MedicationViewModel) {
        self.medication = medication
        self.medVM = medVM
        _name = State(initialValue: medication.name)
        _dosage = State(initialValue: medication.dosage)
        _frequency = State(initialValue: medication.frequency)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        _scheduleTime = State(initialValue: formatter.date(from: medication.scheduleTime) ?? Date())
    }

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
            .navigationTitle("Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty || isSaving)
                }
            }
        }
    }

    private func save() {
        guard let id = medication.id else { return }
        isSaving = true
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: scheduleTime)
        Firestore.firestore().collection("medications").document(id).updateData([
            "name": name,
            "dosage": dosage,
            "frequency": frequency,
            "scheduleTime": timeString
        ]) { _ in
            isSaving = false
            dismiss()
        }
    }
}
