import Foundation
import FirebaseFirestore

struct StrideUser: Codable, Identifiable {
    @DocumentID var id: String?
    var fullName: String
    var email: String
    var phoneNumber: String
    var role: String
    var createdAt: Date?
}
