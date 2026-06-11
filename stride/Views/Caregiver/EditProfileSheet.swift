import SwiftUI
import FirebaseFirestore

struct EditProfileSheet: View {
    let elderlyID: String
    let profile: ElderlyProfile
    let onSave: (ElderlyProfile) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var fullName: String
    @State private var age: String
    @State private var heightStr: String
    @State private var weightStr: String
    @State private var bloodType: String
    @State private var medicalNotes: String
    @State private var notes: String
    @State private var heartRateStr: String
    @State private var stressPercentageStr: String
    @State private var sleepAwakeMinStr: String
    @State private var sleepREMMinStr: String
    @State private var sleepCoreMinStr: String
    @State private var sleepDeepMinStr: String
    @State private var isSaving = false

    init(elderlyID: String, profile: ElderlyProfile, onSave: @escaping (ElderlyProfile) -> Void) {
        self.elderlyID = elderlyID
        self.profile = profile
        self.onSave = onSave
        _fullName = State(initialValue: profile.fullName)
        _age = State(initialValue: "\(profile.age)")
        _heightStr = State(initialValue: profile.height != nil ? String(format: "%.0f", profile.height!) : "")
        _weightStr = State(initialValue: profile.weight != nil ? String(format: "%.0f", profile.weight!) : "")
        _bloodType = State(initialValue: profile.bloodType ?? "")
        _medicalNotes = State(initialValue: profile.medicalNotes ?? "")
        _notes = State(initialValue: profile.notes ?? "")
        _heartRateStr = State(initialValue: profile.heartRate != nil ? "\(profile.heartRate!)" : "")
        _stressPercentageStr = State(initialValue: profile.stressPercentage != nil ? "\(profile.stressPercentage!)" : "")
        _sleepAwakeMinStr = State(initialValue: profile.sleepAwakeMin != nil ? "\(profile.sleepAwakeMin!)" : "")
        _sleepREMMinStr = State(initialValue: profile.sleepREMMin != nil ? "\(profile.sleepREMMin!)" : "")
        _sleepCoreMinStr = State(initialValue: profile.sleepCoreMin != nil ? "\(profile.sleepCoreMin!)" : "")
        _sleepDeepMinStr = State(initialValue: profile.sleepDeepMin != nil ? "\(profile.sleepDeepMin!)" : "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Full Name", text: $fullName)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Physical")) {
                    TextField("Height (cm)", text: $heightStr)
                        .keyboardType(.decimalPad)
                    TextField("Weight (kg)", text: $weightStr)
                        .keyboardType(.decimalPad)
                    TextField("Blood Type", text: $bloodType)
                }
                Section(header: Text("Health Metrics")) {
                    TextField("Heart Rate (BPM)", text: $heartRateStr)
                        .keyboardType(.numberPad)
                    TextField("Stress (%)", text: $stressPercentageStr)
                        .keyboardType(.numberPad)
                    TextField("Sleep Awake (min)", text: $sleepAwakeMinStr)
                        .keyboardType(.numberPad)
                    TextField("Sleep REM (min)", text: $sleepREMMinStr)
                        .keyboardType(.numberPad)
                    TextField("Sleep Core (min)", text: $sleepCoreMinStr)
                        .keyboardType(.numberPad)
                    TextField("Sleep Deep (min)", text: $sleepDeepMinStr)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Notes")) {
                    TextField("Medical Notes", text: $medicalNotes, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("General Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(fullName.isEmpty || isSaving)
                }
            }
        }
    }

    private func save() {
        isSaving = true
        var data: [String: Any] = [
            "fullName": fullName,
            "bloodType": bloodType,
            "medicalNotes": medicalNotes,
            "notes": notes
        ]
        if let ageInt = Int(age) {
            data["age"] = ageInt
        }
        if let h = Double(heightStr) {
            data["height"] = h
        }
        if let w = Double(weightStr) {
            data["weight"] = w
        }
        
        if let hr = Int(heartRateStr) {
            data["heartRate"] = hr
        } else {
            data["heartRate"] = FieldValue.delete()
        }
        if let stress = Int(stressPercentageStr) {
            data["stressPercentage"] = stress
        } else {
            data["stressPercentage"] = FieldValue.delete()
        }
        if let awake = Int(sleepAwakeMinStr) {
            data["sleepAwakeMin"] = awake
        } else {
            data["sleepAwakeMin"] = FieldValue.delete()
        }
        if let rem = Int(sleepREMMinStr) {
            data["sleepREMMin"] = rem
        } else {
            data["sleepREMMin"] = FieldValue.delete()
        }
        if let core = Int(sleepCoreMinStr) {
            data["sleepCoreMin"] = core
        } else {
            data["sleepCoreMin"] = FieldValue.delete()
        }
        if let deep = Int(sleepDeepMinStr) {
            data["sleepDeepMin"] = deep
        } else {
            data["sleepDeepMin"] = FieldValue.delete()
        }

        Firestore.firestore().collection("elderlyProfiles").document(elderlyID).updateData(data) { _ in
            isSaving = false
            var updated = profile
            updated.fullName = fullName
            if let ageInt = Int(age) { updated.age = ageInt }
            updated.height = Double(heightStr)
            updated.weight = Double(weightStr)
            updated.bloodType = bloodType.isEmpty ? nil : bloodType
            updated.medicalNotes = medicalNotes.isEmpty ? nil : medicalNotes
            updated.notes = notes.isEmpty ? nil : notes
            updated.heartRate = Int(heartRateStr)
            updated.stressPercentage = Int(stressPercentageStr)
            updated.sleepAwakeMin = Int(sleepAwakeMinStr)
            updated.sleepREMMin = Int(sleepREMMinStr)
            updated.sleepCoreMin = Int(sleepCoreMinStr)
            updated.sleepDeepMin = Int(sleepDeepMinStr)
            onSave(updated)
            dismiss()
        }
    }
}
