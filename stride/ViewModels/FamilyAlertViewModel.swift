import Foundation
import FirebaseFirestore
import Combine

class FamilyAlertViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var elderlyNames: [String: String] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var alertsListener: ListenerRegistration?
    private var familyIDs: [String] = []
    
    func startAlertsListener(userID: String) {
        isLoading = true
        
        db.collection("familyMembers")
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                self.familyIDs = documents.compactMap { try? $0.data(as: FamilyMember.self).familyID }
                
                if self.familyIDs.isEmpty {
                    self.isLoading = false
                    self.alerts = []
                    return
                }
                
                self.fetchElderlyNames()
                self.listenToAlerts()
            }
    }
    
    private func fetchElderlyNames() {
        db.collection("elderlyProfiles")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                var names: [String: String] = [:]
                for doc in documents {
                    if let profile = try? doc.data(as: ElderlyProfile.self), let id = profile.id {
                        names[id] = profile.fullName
                    }
                }
                self.elderlyNames = names
            }
    }
    
    private func listenToAlerts() {
        alertsListener?.remove()
        
        guard !familyIDs.isEmpty else {
            self.isLoading = false
            return
        }
        
        alertsListener = db.collection("alerts")
            .whereField("familyID", in: familyIDs)
            .order(by: "triggeredAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.alerts = documents.compactMap { try? $0.data(as: Alert.self) }
            }
    }
    
    func markAllAsSeen(userID: String) {
        for alert in alerts {
            guard let id = alert.id else { continue }
            let seen = alert.seenBy ?? []
            if !seen.contains(userID) {
                db.collection("alerts").document(id).updateData([
                    "seenBy": FieldValue.arrayUnion([userID])
                ])
            }
        }
    }
    
    var unresolvedCount: Int {
        alerts.filter { !$0.isResolved }.count
    }
    
    deinit {
        alertsListener?.remove()
    }
}
