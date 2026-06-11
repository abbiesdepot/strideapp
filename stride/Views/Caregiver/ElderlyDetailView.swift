import SwiftUI
import FirebaseFirestore

struct ElderlyDetailView: View {
    let elderlyID: String

    @State private var profile: ElderlyProfile?
    @State private var isLoadingProfile = true

    @State private var selectedTab = 0
    @State private var showEditSheet = false

    @StateObject private var medVM = MedicationViewModel()
    @State private var showAddMedSheet = false
    @State private var selectedMedication: Medication? = nil
    @State private var showDeleteConfirmAlert = false
    @State private var medicationToDelete: Medication? = nil

    @StateObject private var activityVM = ActivityViewModel()
    @State private var showAddActivitySheet = false
    @State private var selectedActivity: CareActivity? = nil
    @State private var showDeleteActivityAlert = false
    @State private var activityToDelete: CareActivity? = nil

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Overview").tag(0)
                Text("Medications").tag(1)
                Text("Activities").tag(2)
                Text("History").tag(3)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.strideBackground)

            if isLoadingProfile && profile == nil {
                Spacer()
                ProgressView()
                Spacer()
            } else if let profile = profile {
                if selectedTab == 0 {
                    overviewTab(profile: profile)
                } else if selectedTab == 1 {
                    medicationsTab
                } else if selectedTab == 2 {
                    activitiesTab
                } else {
                    historyTab
                }
            } else {
                Spacer()
                Text("Could not load profile.")
                    .foregroundColor(.strideTextSecondary)
                Spacer()
            }
        }
        .background(Color.strideBackground.ignoresSafeArea())
        .navigationTitle("Profile Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if selectedTab == 0 {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showEditSheet = true }) {
                        Image(systemName: "pencil")
                    }
                }
            } else if selectedTab == 1 {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddMedSheet = true }) {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                    }
                }
            } else if selectedTab == 2 {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddActivitySheet = true }) {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .task {
            await loadProfile()
        }
        .onAppear {
            medVM.fetchMedications(elderlyID: elderlyID)
            activityVM.fetchActivities(elderlyID: elderlyID)
        }
        .sheet(isPresented: $showEditSheet) {
            if let profile = profile {
                EditProfileSheet(elderlyID: elderlyID, profile: profile) { updated in
                    self.profile = updated
                }
            }
        }
        .sheet(isPresented: $showAddMedSheet) {
            AddMedicationSheet(elderlyID: elderlyID, medVM: medVM)
        }
        .sheet(item: $selectedMedication) { med in
            EditMedicationSheet(medication: med, medVM: medVM)
        }
        .sheet(isPresented: $showAddActivitySheet) {
            AddActivitySheet(elderlyID: elderlyID, activityVM: activityVM)
        }
        .sheet(item: $selectedActivity) { act in
            EditActivitySheet(activity: act, activityVM: activityVM)
        }
        .alert("Delete Medication?", isPresented: $showDeleteConfirmAlert) {
            Button("Delete", role: .destructive) {
                if let med = medicationToDelete, let id = med.id {
                    medVM.deleteMedication(medicationID: id)
                }
                medicationToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                medicationToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .alert("Delete Activity?", isPresented: $showDeleteActivityAlert) {
            Button("Delete", role: .destructive) {
                if let act = activityToDelete, let id = act.id {
                    activityVM.deleteActivity(activityID: id)
                }
                activityToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                activityToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func loadProfile() async {
        isLoadingProfile = true
        do {
            let snapshot = try await Firestore.firestore()
                .collection("elderlyProfiles")
                .document(elderlyID)
                .getDocument()
            profile = try snapshot.data(as: ElderlyProfile.self)
        } catch {
            profile = nil
        }
        isLoadingProfile = false
    }


    @ViewBuilder
    private func overviewTab(profile: ElderlyProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {

                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.strideTertiary.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.stridePrimary)
                        )

                    Text(profile.fullName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.stridePrimary)

                    Text("\(profile.age) Years Old")
                        .font(.system(size: 16))
                        .foregroundColor(.strideTextSecondary)

                    LiveStatusBadge(status: profile.liveStatus)
                }
                .padding(.top, 24)

                HStack {
                    ProfileStatItem(icon: "figure.walk", value: profile.stepCount != nil ? "\(profile.stepCount!)" : "—", label: "Steps today")
                    Spacer()
                    ProfileStatItem(icon: "map", value: profile.distanceKM != nil ? String(format: "%.1f km", profile.distanceKM!) : "—", label: "Distance")
                    Spacer()
                    ProfileStatItem(icon: "heart.fill", value: profile.heartRate != nil ? "\(profile.heartRate!) bpm" : "—", label: "Heart Rate")
                }
                .padding(20)
                .background(Color.strideCardWhite)
                .cornerRadius(StrideTheme.cornerRadiusCard)
                .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Physical Information")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.stridePrimary)

                    HStack(spacing: 12) {
                        InfoTile(
                            icon: "ruler",
                            iconColor: .strideSecondary,
                            label: "Height",
                            value: profile.height != nil ? String(format: "%.0f cm", profile.height!) : "—"
                        )
                        InfoTile(
                            icon: "scalemass",
                            iconColor: .strideSecondary,
                            label: "Weight",
                            value: profile.weight != nil ? String(format: "%.0f kg", profile.weight!) : "—"
                        )
                        InfoTile(
                            icon: "drop.fill",
                            iconColor: .strideRed,
                            label: "Blood Type",
                            value: profile.bloodType ?? "—"
                        )
                    }
                }
                .padding(.horizontal, 24)

                if let medicalNotes = profile.medicalNotes, !medicalNotes.isEmpty {
                    NoteCard(
                        icon: "heart.text.square",
                        iconColor: .strideRed,
                        title: "Medical Notes",
                        content: medicalNotes
                    )
                    .padding(.horizontal, 24)
                }

                if let notes = profile.notes, !notes.isEmpty {
                    NoteCard(
                        icon: "note.text",
                        iconColor: .strideSecondary,
                        title: "General Notes",
                        content: notes
                    )
                    .padding(.horizontal, 24)
                }

                if !profile.liveStatusReason.isEmpty {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.strideSecondary)
                        Text(profile.liveStatusReason)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.strideTextPrimary)
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.strideSecondary.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: 16)
            }
        }
        .background(Color.strideBackground.ignoresSafeArea())
    }

    @ViewBuilder
    private var medicationsTab: some View {
        if medVM.isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else if medVM.medications.isEmpty {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "pills")
                    .font(.system(size: 60))
                    .foregroundColor(.strideSecondary)
                Text("No Medications")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.stridePrimary)
                Text("Tap + to add a medication.")
                    .foregroundColor(.strideTextSecondary)
            }
            Spacer()
        } else {
            List {
                ForEach(medVM.medications) { med in
                    Button(action: { selectedMedication = med }) {
                        MedicationRow(medication: med)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            medicationToDelete = med
                            showDeleteConfirmAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowBackground(Color.strideBackground)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                }
            }
            .listStyle(.plain)
            .background(Color.strideBackground)
        }
    }

    @ViewBuilder
    private var activitiesTab: some View {
        if activityVM.isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else if activityVM.activities.isEmpty {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "figure.run")
                    .font(.system(size: 60))
                    .foregroundColor(.strideSecondary)
                Text("No Activities")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.stridePrimary)
                Text("Tap + to add an activity.")
                    .foregroundColor(.strideTextSecondary)
            }
            Spacer()
        } else {
            List {
                ForEach(activityVM.activities) { act in
                    Button(action: { selectedActivity = act }) {
                        ActivityRow(activity: act)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            activityToDelete = act
                            showDeleteActivityAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowBackground(Color.strideBackground)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                }
            }
            .listStyle(.plain)
            .background(Color.strideBackground)
        }
    }

    @ViewBuilder
    private var historyTab: some View {
        WeeklyHealthTrendView()
    }
}

private struct MedicationRow: View {
    let medication: Medication

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.strideSecondary.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "pills.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.strideSecondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.stridePrimary)
                Text(medication.dosage)
                    .font(.system(size: 14))
                    .foregroundColor(.strideTextSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(medication.scheduleTime)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.strideSecondary)
                Text(medication.frequency)
                    .font(.system(size: 12))
                    .foregroundColor(.strideTextSecondary)
            }
        }
        .padding(14)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
    }
}

private struct EditProfileSheet: View {
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

private struct AddMedicationSheet: View {
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

private struct EditMedicationSheet: View {
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

private struct ProfileStatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.strideSecondary)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.strideTextPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.strideTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct InfoTile: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(iconColor)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.strideTextPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.strideTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
    }
}

private struct NoteCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.strideTextPrimary)
                Spacer()
            }
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(.strideTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
    }
}

private struct ActivityRow: View {
    let activity: CareActivity

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.strideSecondary.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "figure.run")
                    .font(.system(size: 20))
                    .foregroundColor(.strideSecondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.stridePrimary)
                Text(activity.frequency)
                    .font(.system(size: 14))
                    .foregroundColor(.strideTextSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(activity.scheduleTime)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.strideSecondary)
            }
        }
        .padding(14)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
    }
}

private struct AddActivitySheet: View {
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

private struct EditActivitySheet: View {
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
