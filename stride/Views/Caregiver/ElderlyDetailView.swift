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
        WeeklyHealthTrendView(elderlyID: elderlyID)
    }
}


