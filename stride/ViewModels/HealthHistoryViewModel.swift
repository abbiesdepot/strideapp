import Foundation
import FirebaseFirestore
import Combine

class HealthHistoryViewModel: ObservableObject {
    @Published var activityLogs: [ActivityLog] = []
    @Published var medicationCompliance: [DailyCompliance] = []
    @Published var fallAlerts: [Alert] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    struct DailyCompliance: Identifiable {
        let id = UUID()
        let date: Date
        let compliancePercentage: Double
    }
    
    func fetchHistoryData(elderlyID: String) {
        isLoading = true
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: startOfToday) ?? Date()
        
        // 1. Fetch Activity Logs
        db.collection("activityLogs")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .whereField("recordedAt", isGreaterThanOrEqualTo: sevenDaysAgo)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                self.activityLogs = documents.compactMap { try? $0.data(as: ActivityLog.self) }
                    .sorted { $0.recordedAt < $1.recordedAt }
                
                // 2. Fetch Medication Logs
                self.fetchMedicationLogs(elderlyID: elderlyID, from: sevenDaysAgo)
            }
    }
    
    private func fetchMedicationLogs(elderlyID: String, from: Date) {
        db.collection("medicationLogs")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .whereField("scheduledTime", isGreaterThanOrEqualTo: from)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                let logs = documents.compactMap { try? $0.data(as: MedicationLog.self) }
                self.calculateCompliance(logs: logs)
                
                // 3. Fetch Fall Alerts
                self.fetchFallAlerts(elderlyID: elderlyID, from: from)
            }
    }
    
    private func calculateCompliance(logs: [MedicationLog]) {
        let calendar = Calendar.current
        var complianceMap: [Date: (taken: Int, total: Int)] = [:]
        
        // Initialize last 7 days
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: calendar.startOfDay(for: Date())) {
                complianceMap[date] = (0, 0)
            }
        }
        
        for log in logs {
            let dayDate = calendar.startOfDay(for: log.scheduledTime)
            if complianceMap[dayDate] == nil {
                complianceMap[dayDate] = (0, 0)
            }
            
            let isTaken = log.status.lowercased() == "taken"
            complianceMap[dayDate]!.total += 1
            if isTaken {
                complianceMap[dayDate]!.taken += 1
            }
        }
        
        self.medicationCompliance = complianceMap.map { (date, value) in
            let percentage = value.total > 0 ? (Double(value.taken) / Double(value.total) * 100.0) : 0.0
            return DailyCompliance(date: date, compliancePercentage: percentage)
        }.sorted { $0.date < $1.date }
    }
    
    private func fetchFallAlerts(elderlyID: String, from: Date) {
        db.collection("alerts")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .whereField("type", isEqualTo: "fall")
            .whereField("triggeredAt", isGreaterThanOrEqualTo: from)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.fallAlerts = documents.compactMap { try? $0.data(as: Alert.self) }
            }
    }
}
