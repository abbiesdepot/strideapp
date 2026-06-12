import Foundation
import FirebaseFirestore

struct ActivityLog: Codable, Identifiable {
    @DocumentID var id: String?
    var elderlyID: String
    var stepCount: Int
    var distanceKM: Double
    var idleMinutes: Int
    var recordedAt: Date
}
