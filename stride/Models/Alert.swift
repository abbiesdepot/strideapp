import Foundation
import FirebaseFirestore

struct Alert: Codable, Identifiable {
    @DocumentID var id: String?
    var elderlyID: String
    var familyID: String
    var type: String // "SOS", "fall", "missed_med", "inactivity", "vital_sign"
    var severity: String // "red" or "yellow"
    var message: String
    var isResolved: Bool
    var triggeredAt: Date
    var seenBy: [String]?
}
