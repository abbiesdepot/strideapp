import Foundation
import FirebaseFirestore
import Combine

@MainActor
class MedicationViewModel: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var todayLogs: [MedicationLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var logsListenerRegistration: ListenerRegistration?
    
    func fetchMedications(elderlyID: String) {
        isLoading = true
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("medications")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.medications = documents.compactMap { try? $0.data(as: Medication.self) }
                    .sorted { $0.scheduleTime < $1.scheduleTime }
            }
    }
    
    func fetchTodayLogs(elderlyID: String) {
        logsListenerRegistration?.remove()
        
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        
        logsListenerRegistration = db.collection("medicationLogs")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .whereField("scheduledTime", isGreaterThanOrEqualTo: startOfToday)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.todayLogs = documents.compactMap { try? $0.data(as: MedicationLog.self) }
            }
    }
    
    func addMedication(elderlyID: String, name: String, dosage: String, frequency: String, scheduleTime: String) {
        let newMed = Medication(
            elderlyID: elderlyID,
            name: name,
            dosage: dosage,
            frequency: frequency,
            scheduleTime: scheduleTime,
            isEnabled: true,
            createdAt: Date()
        )
        
        do {
            try db.collection("medications").addDocument(from: newMed)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func toggleMedicationStatus(medication: Medication) {
        guard let id = medication.id else { return }
        db.collection("medications").document(id).updateData([
            "isEnabled": !medication.isEnabled
        ])
    }
    
    func takeMedication(medication: Medication) {
        guard let medID = medication.id else { return }
        
        let now = Date()
        let log = MedicationLog(
            medicationID: medID,
            elderlyID: medication.elderlyID,
            scheduledTime: now,
            confirmedAt: now,
            status: "taken"
        )
        
        do {
            try db.collection("medicationLogs").addDocument(from: log)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func untakeMedication(medicationID: String) {
        let todayLog = todayLogs.first { $0.medicationID == medicationID }
        guard let logID = todayLog?.id else { return }
        
        db.collection("medicationLogs").document(logID).delete() { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    func deleteMedication(medicationID: String) {
        db.collection("medications").document(medicationID).delete()
    }
    
    deinit {
        listenerRegistration?.remove()
        logsListenerRegistration?.remove()
    }
}
