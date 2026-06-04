import Foundation
import FirebaseFirestore
import Combine

class MedicationViewModel: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
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
    
    func deleteMedication(medicationID: String) {
        db.collection("medications").document(medicationID).delete()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
