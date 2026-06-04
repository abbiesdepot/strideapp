import Foundation
import FirebaseFirestore
import Combine

class AlertViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    func fetchAlerts(familyID: String) {
        isLoading = true
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("alerts")
            .whereField("familyID", isEqualTo: familyID)
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
                self.unreadCount = self.alerts.filter { !$0.isResolved }.count
            }
    }
    
    func markResolved(alertID: String) {
        db.collection("alerts").document(alertID).updateData([
            "isResolved": true
        ])
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
