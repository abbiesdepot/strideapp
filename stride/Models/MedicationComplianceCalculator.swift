import Foundation

struct MedicationComplianceCalculator {
    static func calculateCompliance(logs: [MedicationLog]) -> Double {
        let total = logs.count
        let taken = logs.filter { $0.status == "taken" }.count
        return total > 0 ? (Double(taken) / Double(total) * 100.0) : 0.0
    }
}
