import SwiftUI

struct MedicationManagerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = MedicationViewModel()
    @StateObject private var dashboardVM = CaregiverDashboardViewModel()
    
    @State private var showingAddMedication = false
    @State private var newMedName = ""
    @State private var newMedDosage = ""
    @State private var newMedFrequency = "Once daily"
    @State private var newMedTime = Date()
    
    let frequencies = ["Once daily", "Twice daily", "Three times daily", "As needed"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.strideBackground.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.medications.isEmpty {
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
                } else {
                    List {
                        ForEach(viewModel.medications) { med in
                            MedicationCard(medication: med) {
                                viewModel.toggleMedicationStatus(medication: med)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                if let id = viewModel.medications[index].id {
                                    viewModel.deleteMedication(medicationID: id)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Medications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMedication = true }) {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                    }
                }
            }
            .onAppear {
                if let uid = authViewModel.currentUser?.id {
                    dashboardVM.fetchDashboardData(caregiverID: uid)
                }
            }
            .onChange(of: dashboardVM.family?.elderlyID) { elderlyID in
                if let elderlyID = elderlyID {
                    viewModel.fetchMedications(elderlyID: elderlyID)
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                NavigationStack {
                    Form {
                        Section(header: Text("Details")) {
                            TextField("Medication Name", text: $newMedName)
                            TextField("Dosage (e.g., 10mg)", text: $newMedDosage)
                            Picker("Frequency", selection: $newMedFrequency) {
                                ForEach(frequencies, id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                        Section(header: Text("Schedule")) {
                            DatePicker("Time", selection: $newMedTime, displayedComponents: .hourAndMinute)
                        }
                    }
                    .navigationTitle("Add Medication")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingAddMedication = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                if let elderlyID = dashboardVM.family?.elderlyID {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "HH:mm"
                                    let timeString = formatter.string(from: newMedTime)
                                    viewModel.addMedication(
                                        elderlyID: elderlyID,
                                        name: newMedName,
                                        dosage: newMedDosage,
                                        frequency: newMedFrequency,
                                        scheduleTime: timeString
                                    )
                                    showingAddMedication = false
                                }
                            }
                            .disabled(newMedName.isEmpty || newMedDosage.isEmpty)
                        }
                    }
                }
            }
        }
    }
}
