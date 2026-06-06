import Foundation
import FirebaseFirestore
import Combine

class FamilyAlertViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var unresolvedCount: Int {
        alerts.filter { !$0.isResolved }.count
    }

    private var db = Firestore.firestore()
    private var alertsListener: ListenerRegistration?
    private var familyIDs: [String] = []

    func startAlertsListener(userID: String) {
        isLoading = true

        db.collection("familyMembers")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }

                let ids = snapshot?.documents
                    .compactMap { try? $0.data(as: FamilyMember.self) }
                    .map { $0.familyID } ?? []

                guard !ids.isEmpty else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.alerts = []
                    }
                    return
                }

                self.familyIDs = ids
                self.listenToAlerts()
            }
    }

    func markAllAsSeen(userID: String) {
        for alert in alerts {
            guard let alertID = alert.id else { continue }
            if alert.seenBy?.contains(userID) == true { continue }
            db.collection("alerts").document(alertID).updateData([
                "seenBy": FieldValue.arrayUnion([userID])
            ])
        }
    }

    deinit {
        alertsListener?.remove()
    }


    private func listenToAlerts() {
        alertsListener?.remove()

        alertsListener = db.collection("alerts")
            .whereField("familyID", in: familyIDs)
            .order(by: "triggeredAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    guard let documents = snapshot?.documents else { return }
                    self.alerts = documents.compactMap { try? $0.data(as: Alert.self) }
                }
            }
    }
}
