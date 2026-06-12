import Foundation
import FirebaseFirestore

struct FamilyMember: Codable, Identifiable {
    @DocumentID var id: String?
    var familyID: String
    var userID: String
    var joinedAt: Date?
}
