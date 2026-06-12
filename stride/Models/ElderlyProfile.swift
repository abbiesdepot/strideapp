import Foundation
import FirebaseFirestore

struct ElderlyProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var fullName: String
    var age: Int
    
    var height: Double?
    var weight: Double?
    var bloodType: String?
    var notes: String?
    
    var photoURL: String?
    var medicalNotes: String?
    var familyID: String?
    var stepCount: Int?
    var distanceKM: Double?
    var heartRate: Int?
    var stressPercentage: Int?
    var sleepAwakeMin: Int?
    var sleepREMMin: Int?
    var sleepCoreMin: Int?
    var sleepDeepMin: Int?
    var liveStatus: String // "green", "yellow", "red"
    var liveStatusReason: String
    var createdAt: Date?
}
