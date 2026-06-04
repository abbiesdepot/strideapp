import Foundation
import FirebaseFirestore
import Combine

@MainActor
class CaregiverDashboardViewModel: ObservableObject {
    @Published var elderlyProfile: ElderlyProfile?
    @Published var family: Family?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Scoped live updates
    @Published var activeMedications: [Medication] = []
    @Published var todayMedicationLogs: [MedicationLog] = []
    @Published var latestVitalSign: VitalSign?
    
    private var db = Firestore.firestore()
    private var profileListener: ListenerRegistration?
    private var medicationsListener: ListenerRegistration?
    private var logsListener: ListenerRegistration?
    private var vitalsListener: ListenerRegistration?
    
    func fetchDashboardData(caregiverID: String) {
        isLoading = true
        db.collection("family")
            .whereField("caregiverID", isEqualTo: caregiverID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    self.isLoading = false
                    return
                }
                
                do {
                    self.family = try document.data(as: Family.self)
                    if let elderlyID = self.family?.elderlyID {
                        self.listenToElderlyData(elderlyID: elderlyID)
                    }
                } catch {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
    }
    
    private func listenToElderlyData(elderlyID: String) {
        listenToElderlyProfile(elderlyID: elderlyID)
        listenToMedications(elderlyID: elderlyID)
        listenToTodayLogs(elderlyID: elderlyID)
        listenToLatestVitals(elderlyID: elderlyID)
        
        // Watch sync trigger
        WatchSessionManager.shared.startMonitoringMedications(elderlyID: elderlyID)
    }
    
    private func listenToElderlyProfile(elderlyID: String) {
        profileListener?.remove()
        profileListener = db.collection("elderlyProfiles").document(elderlyID)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = documentSnapshot else {
                    self.errorMessage = "Elderly profile not found."
                    return
                }
                
                do {
                    self.elderlyProfile = try document.data(as: ElderlyProfile.self)
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
    }
    
    private func listenToMedications(elderlyID: String) {
        medicationsListener?.remove()
        medicationsListener = db.collection("medications")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .whereField("isEnabled", isEqualTo: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                self.activeMedications = documents.compactMap { try? $0.data(as: Medication.self) }
            }
    }
    
    private func listenToTodayLogs(elderlyID: String) {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        logsListener?.remove()
        logsListener = db.collection("medicationLogs")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .whereField("scheduledTime", isGreaterThanOrEqualTo: startOfDay)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                self.todayMedicationLogs = documents.compactMap { try? $0.data(as: MedicationLog.self) }
            }
    }
    
    private func listenToLatestVitals(elderlyID: String) {
        vitalsListener?.remove()
        vitalsListener = db.collection("vitalSigns")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .order(by: "recordedAt", descending: true)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                self.latestVitalSign = documents.first.flatMap { try? $0.data(as: VitalSign.self) }
            }
    }
    
    var lastActiveText: String {
        guard let lastTime = latestVitalSign?.recordedAt else {
            return "No activity recorded"
        }
        let diff = Int(Date().timeIntervalSince(lastTime))
        if diff < 60 {
            return "Last active just now"
        } else if diff < 3600 {
            return "Last active \(diff / 60) min ago"
        } else {
            let hours = diff / 3600
            if hours < 24 {
                return "Last active \(hours) hr ago"
            } else {
                return "Last active \(hours / 24) days ago"
            }
        }
    }
    
    var medicationComplianceText: String {
        let takenCount = todayMedicationLogs.filter { $0.status == "taken" }.count
        let totalCount = max(todayMedicationLogs.count, activeMedications.count)
        return "\(takenCount) of \(totalCount) medications taken"
    }
    
    func createElderlyProfile(caregiverID: String, fullName: String, age: Int, medicalNotes: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        let newElderly = ElderlyProfile(
            fullName: fullName,
            age: age,
            photoURL: nil,
            medicalNotes: medicalNotes,
            familyID: nil,
            stepCount: 0,
            distanceKM: 0.0,
            liveStatus: "green",
            liveStatusReason: "Setup complete",
            createdAt: Date()
        )
        
        do {
            let ref = try db.collection("elderlyProfiles").addDocument(from: newElderly) { error in
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
            }
            
            let elderlyID = ref.documentID
            let inviteCode = String((0..<6).map{ _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
            
            let newFamily = Family(
                caregiverID: caregiverID,
                elderlyID: elderlyID,
                inviteCode: inviteCode,
                createdAt: Date()
            )
            
            _ = try db.collection("family").addDocument(from: newFamily) { error in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.db.collection("elderlyProfiles").document(elderlyID).updateData([
                        "familyID": newFamily.id ?? ""
                    ])
                    completion(true)
                }
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            completion(false)
        }
    }
    
    deinit {
        profileListener?.remove()
        medicationsListener?.remove()
        logsListener?.remove()
        vitalsListener?.remove()
    }
}
