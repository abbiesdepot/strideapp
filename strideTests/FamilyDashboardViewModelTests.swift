import XCTest
@testable import stride
import FirebaseCore

final class FamilyDashboardViewModelTests: XCTestCase {
    
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
        let viewModel = FamilyDashboardViewModel()
        XCTAssertTrue(viewModel.elderlyProfiles.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testMockAddProfiles() {
        let viewModel = FamilyDashboardViewModel()
        let profile1 = ElderlyProfile(
            id: "elder_01",
            fullName: "Elder One",
            age: 78,
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
            liveStatusReason: "Okay",
            createdAt: Date()
        )
        let profile2 = ElderlyProfile(
            id: "elder_02",
            fullName: "Elder Two",
            age: 82,
            height: nil,
            weight: nil,
            bloodType: nil,
            notes: nil,
            photoURL: nil,
            medicalNotes: nil,
            familyID: "fam_02",
            stepCount: nil,
            distanceKM: nil,
            heartRate: nil,
            stressPercentage: nil,
            sleepAwakeMin: nil,
            sleepREMMin: nil,
            sleepCoreMin: nil,
            sleepDeepMin: nil,
            liveStatus: "yellow",
            liveStatusReason: "Check medications",
            createdAt: Date()
        )
        
        viewModel.elderlyProfiles = [profile1, profile2]
        
        XCTAssertEqual(viewModel.elderlyProfiles.count, 2)
        XCTAssertEqual(viewModel.elderlyProfiles[0].fullName, "Elder One")
        XCTAssertEqual(viewModel.elderlyProfiles[1].fullName, "Elder Two")
    }
}
