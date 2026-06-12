import Foundation
import FirebaseFirestore

struct Family: Codable, Identifiable {
    @DocumentID var id: String?
    var caregiverID: String
    var elderlyID: String
    var inviteCode: String
    var createdAt: Date?
}
