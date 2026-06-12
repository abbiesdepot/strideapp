import XCTest
@testable import stride
import FirebaseCore

final class CaregiverDashboardViewModelTests: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        if FirebaseApp.app() == nil {
            let options = FirebaseOptions(googleAppID: "1:1234567890:ios:1234567890", gcmSenderID: "1234567890")
            options.apiKey = "MockAPIKeyForTesting"
            options.projectID = "stride-mock-db"
            FirebaseApp.configure(options: options)
        }
        try await Task.sleep(nanoseconds: 100_000_000)
    }
    
    @MainActor
    func testInitialState() {
        let viewModel = CaregiverDashboardViewModel()
        XCTAssertNil(viewModel.elderlyProfile)
        XCTAssertNil(viewModel.family)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testMockSetProfile() {
        let viewModel = CaregiverDashboardViewModel()
        let sampleProfile = ElderlyProfile(
            id: "elder_01",
            fullName: "John Doe",
            age: 80,
            height: 170.0,
            weight: 70.0,
            bloodType: "A+",
            notes: "Needs help walking",
            photoURL: nil,
            medicalNotes: "Hypertension",
            familyID: "fam_01",
            stepCount: 2000,
            distanceKM: 1.5,
            heartRate: 75,
            stressPercentage: 20,
            sleepAwakeMin: 10,
            sleepREMMin: 60,
            sleepCoreMin: 200,
            sleepDeepMin: 80,
            liveStatus: "green",
            liveStatusReason: "Healthy",
            createdAt: Date()
        )
        viewModel.elderlyProfile = sampleProfile
        
        XCTAssertNotNil(viewModel.elderlyProfile)
        XCTAssertEqual(viewModel.elderlyProfile?.fullName, "John Doe")
        XCTAssertEqual(viewModel.elderlyProfile?.age, 80)
        XCTAssertEqual(viewModel.elderlyProfile?.liveStatus, "green")
    }
}
