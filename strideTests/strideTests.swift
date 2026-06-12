import XCTest
@testable import stride
import FirebaseCore

/// General model-level smoke tests (struct initialisation via StrideMockData)
final class strideTests: XCTestCase {

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

    // MARK: - Model struct sanity checks (uses StrideMockData)

    func testStrideUserInitialization() throws {
        let user = StrideMockData.sampleCaregiver
        XCTAssertEqual(user.id, "user_test_01")
        XCTAssertEqual(user.fullName, "Abbie Test")
        XCTAssertEqual(user.role, "caregiver")
    }

    func testMedicationInitialization() throws {
        let med = StrideMockData.sampleMedication
        XCTAssertEqual(med.name, "Paracetamol")
        XCTAssertEqual(med.dosage, "500mg")
        XCTAssertTrue(med.isEnabled)
    }

    @MainActor
    func testFamilyDashboardInitialState() throws {
        let viewModel = FamilyDashboardViewModel()
        XCTAssertTrue(viewModel.elderlyProfiles.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
}
