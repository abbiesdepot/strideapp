import Foundation
import FirebaseFirestore

struct CareActivity: Codable, Identifiable {
    @DocumentID var id: String?
    var elderlyID: String
    var name: String
    var frequency: String
    var scheduleTime: String
    var isEnabled: Bool
    var createdAt: Date?
}
