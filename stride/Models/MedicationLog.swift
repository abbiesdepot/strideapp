import Foundation
import FirebaseFirestore

struct MedicationLog: Codable, Identifiable {
    @DocumentID var id: String?
    var medicationID: String
    var elderlyID: String
    var scheduledTime: Date
    var confirmedAt: Date?
    var status: String // "taken" or "missed"
}
