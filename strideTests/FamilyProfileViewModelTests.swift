import XCTest
@testable import stride
import FirebaseCore

final class FamilyProfileViewModelTests: XCTestCase {
    
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
    
    func testInitialState() {
        let viewModel = FamilyProfileViewModel()
        XCTAssertTrue(viewModel.careCircles.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testMockCareCircles() {
        let viewModel = FamilyProfileViewModel()
        let elderly = ElderlyProfile(
            id: "elder_01",
            fullName: "Elderly User",
            age: 85,
            height: nil,
            weight: nil,
            bloodType: nil,
            notes: nil,
            photoURL: nil,
            medicalNotes: nil,
            familyID: "fam_01",
            stepCount: nil,
            distanceKM: nil,
            heartRate: nil,
            stressPercentage: nil,
            sleepAwakeMin: nil,
            sleepREMMin: nil,
            sleepCoreMin: nil,
            sleepDeepMin: nil,
            liveStatus: "green",
            liveStatusReason: "Healthy",
            createdAt: Date()
        )
        let detail = CareCircleDetail(
            id: "circle_01",
            memberDocID: "member_01",
            familyID: "fam_01",
            elderlyProfile: elderly,
            caregiverName: "Abbie"
        )
        
        viewModel.careCircles = [detail]
        XCTAssertEqual(viewModel.careCircles.count, 1)
        XCTAssertEqual(viewModel.careCircles.first?.elderlyProfile.fullName, "Elderly User")
        XCTAssertEqual(viewModel.careCircles.first?.caregiverName, "Abbie")
    }
}
