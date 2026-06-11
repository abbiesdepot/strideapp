import Foundation
import FirebaseFirestore
import Combine

@MainActor
class DailyReportViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Average calculated values
    @Published var averageHeartRate: Double = 0
    @Published var averageSpO2: Double = 0
    @Published var averageSteps: Double = 0
    @Published var averageDistance: Double = 0
    @Published var averageIdleMinutes: Double = 0
    @Published var medicationCompliance: Double = 0
    
    // Original lists
    @Published var vitalSigns: [VitalSign] = []
    @Published var activityLogs: [ActivityLog] = []
    @Published var medicationLogs: [MedicationLog] = []
    
    private var db = Firestore.firestore()
    
    func fetchDailyReport(elderlyID: String) {
        isLoading = true
        
        let group = DispatchGroup()
        
        // Fetch Vitals
        group.enter()
        db.collection("vitalSigns")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { group.leave(); return }
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let docs = snapshot?.documents {
                    self.vitalSigns = docs.compactMap { try? $0.data(as: VitalSign.self) }
                        .sorted { $0.recordedAt > $1.recordedAt }
                    self.calculateVitalsAverages()
                }
                group.leave()
            }
        
        // Fetch Activity Logs
        group.enter()
        db.collection("activityLogs")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { group.leave(); return }
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let docs = snapshot?.documents {
                    self.activityLogs = docs.compactMap { try? $0.data(as: ActivityLog.self) }
                        .sorted { $0.recordedAt > $1.recordedAt }
                    self.calculateActivityAverages()
                }
                group.leave()
            }
            
        // Fetch Medication Logs
        group.enter()
        db.collection("medicationLogs")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { group.leave(); return }
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let docs = snapshot?.documents {
                    self.medicationLogs = docs.compactMap { try? $0.data(as: MedicationLog.self) }
                    self.calculateMedicationCompliance()
                }
                group.leave()
            }
            
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    private func calculateVitalsAverages() {
        guard !vitalSigns.isEmpty else {
            averageHeartRate = 0
            averageSpO2 = 0
            return
        }
        
        let hrSum = vitalSigns.reduce(0.0) { $0 + $1.heartRate }
        averageHeartRate = hrSum / Double(vitalSigns.count)
        
        let spo2Sum = vitalSigns.reduce(0.0) { $0 + $1.spO2 }
        averageSpO2 = spo2Sum / Double(vitalSigns.count)
    }
    
    private func calculateActivityAverages() {
        guard !activityLogs.isEmpty else {
            averageSteps = 0
            averageDistance = 0
            averageIdleMinutes = 0
            return
        }
        
        let stepsSum = activityLogs.reduce(0.0) { $0 + Double($1.stepCount) }
        averageSteps = stepsSum / Double(activityLogs.count)
        
        let distSum = activityLogs.reduce(0.0) { $0 + $1.distanceKM }
        averageDistance = distSum / Double(activityLogs.count)
        
        let idleSum = activityLogs.reduce(0.0) { $0 + Double($1.idleMinutes) }
        averageIdleMinutes = idleSum / Double(activityLogs.count)
    }
    
    private func calculateMedicationCompliance() {
        guard !medicationLogs.isEmpty else {
            medicationCompliance = 0
            return
        }
        
        let takenCount = medicationLogs.filter { $0.status == "taken" }.count
        medicationCompliance = (Double(takenCount) / Double(medicationLogs.count)) * 100.0
    }
}
