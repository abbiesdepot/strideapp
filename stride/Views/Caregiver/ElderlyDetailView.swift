import SwiftUI
import FirebaseFirestore

struct ElderlyDetailView: View {
    let elderlyID: String
    
    @State private var selectedTab = 0
    private let tabs = ["Overview", "Medications", "History"]
    
    // Firestore Listeners
    @State private var profile: ElderlyProfile? = nil
    @State private var latestVitals: VitalSign? = nil
    @State private var profileListener: ListenerRegistration? = nil
    @State private var vitalsListener: ListenerRegistration? = nil
    
    // Medications ViewModel
    @StateObject private var medVM = MedicationViewModel()
    
    // Editing Profile Sheet
    @State private var showingEditProfile = false
    @State private var editName = ""
    @State private var editAge = ""
    @State private var editWeight = ""
    @State private var editHeight = ""
    @State private var editBloodType = "A+"
    @State private var editNotes = ""
    
    let bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "Unknown"]
    
    // Medication Action States
    @State private var showingMedSheet = false
    @State private var selectedMedication: Medication? = nil // nil for Add, non-nil for Edit
    @State private var medName = ""
    @State private var medDosage = ""
    @State private var medFrequency = "Once daily"
    @State private var medTime = Date()
    @State private var medNotes = ""
    @State private var medToDelete: Medication? = nil
    @State private var showingDeleteMedAlert = false
    
    let frequencies = ["Once daily", "Twice daily", "Three times daily", "As needed"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Picker
            Picker("Section", selection: $selectedTab) {
                ForEach(0..<tabs.count, id: \.self) { i in
                    Text(tabs[i])
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color.strideCardWhite)
            
            Group {
                if selectedTab == 0 {
                    overviewSection
                } else if selectedTab == 1 {
                    medicationsSection
                } else {
                    historySection
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.strideBackground.ignoresSafeArea())
        .navigationTitle(profile?.fullName ?? "Elderly Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if selectedTab == 0 {
                    Button(action: {
                        if let profile = profile {
                            editName = profile.fullName
                            editAge = "\(profile.age)"
                            editWeight = profile.weight != nil ? "\(profile.weight!)" : ""
                            editHeight = profile.height != nil ? "\(profile.height!)" : ""
                            editBloodType = profile.bloodType ?? "A+"
                            editNotes = profile.medicalNotes ?? ""
                            showingEditProfile = true
                        }
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.stridePrimary)
                    }
                } else if selectedTab == 1 {
                    Button(action: {
                        selectedMedication = nil
                        medName = ""
                        medDosage = ""
                        medFrequency = "Once daily"
                        medTime = Date()
                        medNotes = ""
                        showingMedSheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.stridePrimary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            editProfileSheet
        }
        .sheet(isPresented: $showingMedSheet) {
            medicationSheet
        }
        .confirmationDialog(
            "Delete medication?",
            isPresented: $showingDeleteMedAlert,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let med = medToDelete, let id = med.id {
                    medVM.deleteMedication(medicationID: id)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \(medToDelete?.name ?? "this medication")?")
        }
        .onAppear {
            setupListeners()
            medVM.fetchMedications(elderlyID: elderlyID)
        }
        .onDisappear {
            removeListeners()
        }
    }
    
    // MARK: - Overview Tab
    private var overviewSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let profile = profile {
                    // Profile Header Card
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.strideSecondary.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.strideSecondary)
                            )
                        
                        Text(profile.fullName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.strideTextPrimary)
                        
                        Text("\(profile.age) years old")
                            .font(.system(size: 15))
                            .foregroundColor(.strideTextSecondary)
                        
                        LiveStatusBadge(status: profile.liveStatus, reason: profile.liveStatusReason)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.strideCardWhite)
                    .cornerRadius(StrideTheme.cornerRadiusCard)
                    
                    // Physical Info Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Physical Metrics")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        
                        HStack {
                            MetricBox(label: "Weight", value: profile.weight != nil ? String(format: "%.1f kg", profile.weight!) : "-- kg")
                            Spacer()
                            MetricBox(label: "Height", value: profile.height != nil ? String(format: "%.0f cm", profile.height!) : "-- cm")
                            Spacer()
                            MetricBox(label: "Blood Type", value: profile.bloodType ?? "--")
                        }
                    }
                    .padding()
                    .background(Color.strideCardWhite)
                    .cornerRadius(StrideTheme.cornerRadiusCard)
                    
                    // Vitals Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Latest Vital Signs")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        
                        if let vitals = latestVitals {
                            HStack {
                                StatItem(icon: "heart.fill", value: "\(Int(vitals.heartRate)) bpm", label: "Heart Rate")
                                Spacer()
                                StatItem(icon: "oxygen.bubble.fill", value: "\(Int(vitals.spO2))%", label: "SpO2 Level")
                                Spacer()
                                StatItem(icon: "clock.fill", value: formatTime(vitals.recordedAt), label: "Recorded")
                            }
                        } else {
                            Text("No vitals recorded yet.")
                                .font(.system(size: 14))
                                .foregroundColor(.strideTextSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)
                        }
                    }
                    .padding()
                    .background(Color.strideCardWhite)
                    .cornerRadius(StrideTheme.cornerRadiusCard)
                    
                    // Activity Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Activity")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        
                        HStack {
                            StatItem(icon: "figure.walk", value: "\(profile.stepCount)", label: "Steps")
                            Spacer()
                            StatItem(icon: "map", value: String(format: "%.1f km", profile.distanceKM), label: "Distance")
                            Spacer()
                            StatItem(icon: "timer", value: "35 min", label: "Idle Time") // Standard idle calculation
                        }
                    }
                    .padding()
                    .background(Color.strideCardWhite)
                    .cornerRadius(StrideTheme.cornerRadiusCard)
                    
                    // Medical Notes Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Medical Notes")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        
                        Text(profile.medicalNotes?.isEmpty == false ? profile.medicalNotes! : "No medical notes entered.")
                            .font(.system(size: 14))
                            .foregroundColor(.strideTextSecondary)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color.strideCardWhite)
                    .cornerRadius(StrideTheme.cornerRadiusCard)
                    
                } else {
                    ProgressView().padding(.top, 50)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Medications Tab
    private var medicationsSection: some View {
        VStack(spacing: 0) {
            if medVM.isLoading {
                ProgressView().padding(.top, 50)
                Spacer()
            } else if medVM.medications.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.strideSecondary.opacity(0.5))
                    Text("No Medications")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.stridePrimary)
                    Text("No scheduled medications found for this elderly person.")
                        .font(.system(size: 14))
                        .foregroundColor(.strideTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        selectedMedication = nil
                        medName = ""
                        medDosage = ""
                        medFrequency = "Once daily"
                        medTime = Date()
                        medNotes = ""
                        showingMedSheet = true
                    }) {
                        Text("+ Add Medication")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.stridePrimary)
                            .cornerRadius(StrideTheme.cornerRadiusButton)
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 60)
                Spacer()
            } else {
                List {
                    ForEach(medVM.medications) { medication in
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(medication.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.strideTextPrimary)
                                
                                HStack(spacing: 8) {
                                    Text(medication.dosage)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.strideSecondary)
                                    
                                    Text("•")
                                        .foregroundColor(.strideNeutral.opacity(0.5))
                                    
                                    Text(medication.frequency)
                                        .font(.system(size: 13))
                                        .foregroundColor(.strideTextSecondary)
                                }
                            }
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 6) {
                                Text(medication.scheduleTime)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.strideTextPrimary)
                                
                                Toggle("", isOn: Binding(
                                    get: { medication.isEnabled },
                                    set: { _ in medVM.toggleMedicationStatus(medication: medication) }
                                ))
                                .labelsHidden()
                                .tint(.strideSecondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedMedication = medication
                            medName = medication.name
                            medDosage = medication.dosage
                            medFrequency = medication.frequency
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            if let date = formatter.date(from: medication.scheduleTime) {
                                medTime = date
                            }
                            showingMedSheet = true
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                medToDelete = medication
                                showingDeleteMedAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    // MARK: - History Tab
    private var historySection: some View {
        WeeklyHealthChartsView(elderlyID: elderlyID)
    }
    
    // MARK: - Edit Profile Sheet
    private var editProfileSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Full Name", text: $editName)
                    TextField("Age", text: $editAge)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Medical Metrics")) {
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("Weight", text: $editWeight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Height (cm)")
                        Spacer()
                        TextField("Height", text: $editHeight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Blood Type", selection: $editBloodType) {
                        ForEach(bloodTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Medical Notes")) {
                    TextField("Notes", text: $editNotes, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingEditProfile = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveElderlyProfile()
                    }
                    .disabled(editName.isEmpty || Int(editAge) == nil)
                }
            }
        }
    }
    
    // MARK: - Add/Edit Medication Sheet
    private var medicationSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $medName)
                    TextField("Dosage (e.g. 500mg, 1 pill)", text: $medDosage)
                    
                    Picker("Frequency", selection: $medFrequency) {
                        ForEach(frequencies, id: \.self) { freq in
                            Text(freq).tag(freq)
                        }
                    }
                }
                
                Section(header: Text("Schedule")) {
                    DatePicker("Schedule Time", selection: $medTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle(selectedMedication == nil ? "Add Medication" : "Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingMedSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMedication()
                    }
                    .disabled(medName.isEmpty || medDosage.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Database Actions
    private func setupListeners() {
        let db = Firestore.firestore()
        
        // Listen to profile
        profileListener = db.collection("elderlyProfiles").document(elderlyID)
            .addSnapshotListener { snapshot, error in
                if let doc = snapshot, doc.exists {
                    self.profile = try? doc.data(as: ElderlyProfile.self)
                }
            }
        
        // Listen to latest vitals
        vitalsListener = db.collection("vitalSigns")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .order(by: "recordedAt", descending: true)
            .limit(to: 1)
            .addSnapshotListener { snapshot, error in
                if let doc = snapshot?.documents.first {
                    self.latestVitals = try? doc.data(as: VitalSign.self)
                }
            }
    }
    
    private func removeListeners() {
        profileListener?.remove()
        vitalsListener?.remove()
    }
    
    private func saveElderlyProfile() {
        let db = Firestore.firestore()
        let weightVal = Double(editWeight)
        let heightVal = Double(editHeight)
        let ageVal = Int(editAge) ?? 0
        
        db.collection("elderlyProfiles").document(elderlyID).updateData([
            "fullName": editName,
            "age": ageVal,
            "weight": weightVal as Any,
            "height": heightVal as Any,
            "bloodType": editBloodType,
            "medicalNotes": editNotes
        ]) { error in
            if error == nil {
                showingEditProfile = false
            }
        }
    }
    
    private func saveMedication() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: medTime)
        
        if let med = selectedMedication, let id = med.id {
            // Edit mode
            medVM.updateMedication(medicationID: id, name: medName, dosage: medDosage, frequency: medFrequency, scheduleTime: timeString)
        } else {
            // Add mode
            medVM.addMedication(elderlyID: elderlyID, name: medName, dosage: medDosage, frequency: medFrequency, scheduleTime: timeString)
        }
        showingMedSheet = false
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MetricBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.strideTextSecondary)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.strideTextPrimary)
        }
        .frame(minWidth: 90)
        .padding(.vertical, 10)
        .background(Color.strideBackground)
        .cornerRadius(8)
    }
}
