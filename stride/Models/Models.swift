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
    var stepCount: Int
    var distanceKM: Double
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

struct Family: Codable, Identifiable {
    @DocumentID var id: String?
    var caregiverID: String
    var elderlyID: String
    var inviteCode: String
    var createdAt: Date?
}

struct FamilyMember: Codable, Identifiable {
    @DocumentID var id: String?
    var familyID: String
    var userID: String
    var joinedAt: Date?
}

struct Medication: Codable, Identifiable {
    @DocumentID var id: String?
    var elderlyID: String
    var name: String
    var dosage: String
    var frequency: String
    var scheduleTime: String
    var isEnabled: Bool
    var createdAt: Date?
}

struct MedicationLog: Codable, Identifiable {
    @DocumentID var id: String?
    var medicationID: String
    var elderlyID: String
    var scheduledTime: Date
    var confirmedAt: Date?
    var status: String // "taken" or "missed"
}

struct ActivityLog: Codable, Identifiable {
    @DocumentID var id: String?
    var elderlyID: String
    var stepCount: Int
    var distanceKM: Double
    var idleMinutes: Int
    var recordedAt: Date
}

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

struct VitalSign: Codable, Identifiable {
    @DocumentID var id: String?
    var elderlyID: String
    var heartRate: Double
    var spO2: Double
    var recordedAt: Date
}
