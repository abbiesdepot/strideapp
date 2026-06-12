import Foundation
import FirebaseFirestore

struct CareActivityLog: Codable, Identifiable {
    @DocumentID var id: String?
    var activityID: String
    var elderlyID: String
    var scheduledTime: Date
    var confirmedAt: Date?
    var status: String // "done" or "missed"
}
