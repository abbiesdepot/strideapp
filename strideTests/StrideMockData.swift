//
//  StrideMockData.swift
//  strideTests
//
//  Created by abbie on 04/06/26.
//

import Foundation
@testable import stride

struct StrideMockData {
    static let sampleCaregiver = StrideUser(
        id: "user_test_01",
        fullName: "Abbie Test",
        email: "abbie@stride.com",
        phoneNumber: "08123456789",
        role: "caregiver",
        createdAt: Date()
    )
    
    static let sampleMedication = Medication(
        id: "med_test_99",
        elderlyID: "elder_test_01",
        name: "Paracetamol",
        dosage: "500mg",
        frequency: "Twice daily",
        scheduleTime: "08:00",
        isEnabled: true,
        createdAt: Date()
    )
}
