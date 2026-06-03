//
//  Models.swift
//  stride
//
//  Created by abbie on 03/06/26.
//

import Foundation
import FirebaseFirestore

// MARK: - User Model
struct StrideUser: Codable, Identifiable {
    @DocumentID var id: String?
    let fullName: String
    let email: String
    let phoneNumber: String
    let role: String // caregiver or family member
    let createdAt: Date
}

struct ElderlyProfile: Codable, Identifiable {
    @DocumentID var id: String?
    let fullName: String
    let age: Int
    let photoURL: String?
    let medicalNotes: String?
    let careCircleID: String // FK -> Family
    let stepCount: Int
    let distanceKM: Double
    let liveStatus: String // "green", "yellow", "red"
    let liveStatusReason: String
    let createdAt: Date
}

struct FamilyCircle: Codable, Identifiable {
    @DocumentID var id: String?
    let caregiverID: String // FK -> Users
    let elderlyID: String // FK -> ElderlyProfiles
    let inviteCode: String // 6 CHARACTERS  BTW!!!!!!!!!!
    let createdAt: Date
}

struct FamilyMember: Codable, Identifiable {
    @DocumentID var id: String?
    let familyID: String
    let userID: String
    let joinedAt: Date
}

struct Medication: Codable, Identifiable {
    @DocumentID var id: String?
    let elderlyID: String
    let name: String
    let dosage: String
    let frequency: String
    let scheduleTime: String
    let isEnabled: Bool
    let createdAt: Date
}

struct AlertEvent: Codable, Identifiable {
    @DocumentID var id: String?
    let elderlyID: String
    let familyID: String
    let type: String //SOS,fall,missed med,inactivity,vital sign
    let severity: String // red yellow
    let message: String
    let isResolved: Bool
    let triggeredAt: Date
}

