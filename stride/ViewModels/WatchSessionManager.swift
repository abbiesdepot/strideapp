import Foundation
import WatchConnectivity
import FirebaseFirestore
import Combine

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    
    private var db = Firestore.firestore()
    private var medicationsListener: ListenerRegistration?
    private var currentElderlyID: String?
    
    override init() {
        super.init()
        setupWatchSession()
    }
    
    func setupWatchSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("WatchConnectivity: iPhone WCSession initialized.")
        }
    }
    
    // Start listening to the elderly's medications so we can sync them to the watch when they change
    func startMonitoringMedications(elderlyID: String) {
        self.currentElderlyID = elderlyID
        medicationsListener?.remove()
        
        medicationsListener = db.collection("medications")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .whereField("isEnabled", isEqualTo: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                let medicationsList = documents.compactMap { doc -> [String: Any]? in
                    guard let med = try? doc.data(as: Medication.self) else { return nil }
                    return [
                        "id": med.id ?? "",
                        "name": med.name,
                        "dosage": med.dosage,
                        "scheduleTime": med.scheduleTime
                    ]
                }
                
                self.syncMedicationsToWatch(medications: medicationsList)
            }
    }
    
    private func syncMedicationsToWatch(medications: [[String: Any]]) {
        guard WCSession.default.isReachable else { return }
        
        let payload: [String: Any] = [
            "type": "syncMedications",
            "medications": medications
        ]
        
        WCSession.default.sendMessage(payload, replyHandler: nil) { error in
            print("WatchConnectivity: Error syncing medications: \(error.localizedDescription)")
        }
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WatchConnectivity: Activation failed: \(error.localizedDescription)")
        } else {
            print("WatchConnectivity: Activated successfully with state: \(activationState.rawValue)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let type = message["type"] as? String,
              let elderlyID = message["elderlyID"] as? String else { return }
        
        print("WatchConnectivity: Received message of type \(type) for elderly \(elderlyID)")
        
        switch type {
        case "SOS":
            handleSOSAlert(elderlyID: elderlyID)
        case "fall":
            handleFallAlert(elderlyID: elderlyID)
        case "cancelSOS":
            handleAlertCancellation(elderlyID: elderlyID, reason: "SOS cancelled")
        case "cancelFall":
            handleAlertCancellation(elderlyID: elderlyID, reason: "Fall alert cancelled")
        case "activity":
            let steps = message["steps"] as? Int ?? 0
            let distance = message["distance"] as? Double ?? 0.0
            handleActivityUpdate(elderlyID: elderlyID, steps: steps, distance: distance)
        case "medicationTaken":
            let medID = message["medicationID"] as? String ?? ""
            handleMedicationTaken(elderlyID: elderlyID, medicationID: medID)
        default:
            break
        }
    }
    
    // MARK: - Handlers
    
    private func handleSOSAlert(elderlyID: String) {
        db.collection("elderlyProfiles").document(elderlyID).getDocument { [weak self] doc, err in
            guard let self = self,
                  let profile = try? doc?.data(as: ElderlyProfile.self),
                  let familyID = profile.familyID else { return }
            
            let newAlert = Alert(
                elderlyID: elderlyID,
                familyID: familyID,
                type: "SOS",
                severity: "red",
                message: "\(profile.fullName) triggered an SOS emergency alert!",
                isResolved: false,
                triggeredAt: Date(),
                seenBy: []
            )
            
            try? self.db.collection("alerts").addDocument(from: newAlert)
            
            self.db.collection("elderlyProfiles").document(elderlyID).updateData([
                "liveStatus": "red",
                "liveStatusReason": "SOS emergency triggered"
            ])
        }
    }
    
    private func handleFallAlert(elderlyID: String) {
        db.collection("elderlyProfiles").document(elderlyID).getDocument { [weak self] doc, err in
            guard let self = self,
                  let profile = try? doc?.data(as: ElderlyProfile.self),
                  let familyID = profile.familyID else { return }
            
            let newAlert = Alert(
                elderlyID: elderlyID,
                familyID: familyID,
                type: "fall",
                severity: "red",
                message: "Fall detected on \(profile.fullName)'s Apple Watch!",
                isResolved: false,
                triggeredAt: Date(),
                seenBy: []
            )
            
            try? self.db.collection("alerts").addDocument(from: newAlert)
            
            self.db.collection("elderlyProfiles").document(elderlyID).updateData([
                "liveStatus": "red",
                "liveStatusReason": "Fall detected"
            ])
        }
    }
    
    private func handleAlertCancellation(elderlyID: String, reason: String) {
        self.db.collection("elderlyProfiles").document(elderlyID).updateData([
            "liveStatus": "green",
            "liveStatusReason": reason
        ])
    }
    
    private func handleActivityUpdate(elderlyID: String, steps: Int, distance: Double) {
        let newLog = ActivityLog(
            elderlyID: elderlyID,
            stepCount: steps,
            distanceKM: distance,
            idleMinutes: 0,
            recordedAt: Date()
        )
        
        try? self.db.collection("activityLogs").addDocument(from: newLog)
        
        self.db.collection("elderlyProfiles").document(elderlyID).updateData([
            "stepCount": steps,
            "distanceKM": distance
        ])
    }
    
    private func handleMedicationTaken(elderlyID: String, medicationID: String) {
        let log = MedicationLog(
            medicationID: medicationID,
            elderlyID: elderlyID,
            scheduledTime: Date(),
            confirmedAt: Date(),
            status: "taken"
        )
        
        try? self.db.collection("medicationLogs").addDocument(from: log)
    }
}
