import Foundation
import FirebaseFirestore

struct VitalSign: Codable, Identifiable {
    @DocumentID var id: String?
    var elderlyID: String
    var heartRate: Double
    var spO2: Double
    var recordedAt: Date
}
