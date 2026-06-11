import Foundation
import FirebaseFirestore
import Combine

@MainActor
class ActivityViewModel: ObservableObject {
    @Published var activities: [CareActivity] = []
    @Published var todayLogs: [CareActivityLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var logsListenerRegistration: ListenerRegistration?
    
    func fetchActivities(elderlyID: String) {
        isLoading = true
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("careActivities")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.activities = documents.compactMap { try? $0.data(as: CareActivity.self) }
                    .sorted { $0.scheduleTime < $1.scheduleTime }
            }
    }
    
    func fetchTodayLogs(elderlyID: String) {
        logsListenerRegistration?.remove()
        
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTodayTimestamp = Timestamp(date: startOfToday)
        
        logsListenerRegistration = db.collection("careActivityLogs")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .whereField("scheduledTime", isGreaterThanOrEqualTo: startOfTodayTimestamp)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.todayLogs = documents.compactMap { try? $0.data(as: CareActivityLog.self) }
            }
    }
    
    func addActivity(elderlyID: String, name: String, frequency: String, scheduleTime: String) {
        let newAct = CareActivity(
            elderlyID: elderlyID,
            name: name,
            frequency: frequency,
            scheduleTime: scheduleTime,
            isEnabled: true,
            createdAt: Date()
        )
        
        do {
            try db.collection("careActivities").addDocument(from: newAct)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func toggleActivityStatus(activity: CareActivity) {
        guard let id = activity.id else { return }
        db.collection("careActivities").document(id).updateData([
            "isEnabled": !activity.isEnabled
        ])
    }
    
    func takeActivity(activity: CareActivity) {
        guard let actID = activity.id else { return }
        
        let now = Date()
        let log = CareActivityLog(
            activityID: actID,
            elderlyID: activity.elderlyID,
            scheduledTime: now,
            confirmedAt: now,
            status: "done"
        )
        
        do {
            try db.collection("careActivityLogs").addDocument(from: log)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func untakeActivity(activityID: String) {
        let matchingLogs = todayLogs.filter { $0.activityID == activityID }
        for log in matchingLogs {
            guard let logID = log.id else { continue }
            db.collection("careActivityLogs").document(logID).delete() { [weak self] error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deleteActivity(activityID: String) {
        db.collection("careActivities").document(activityID).delete()
    }
    
    deinit {
        listenerRegistration?.remove()
        logsListenerRegistration?.remove()
    }
}
