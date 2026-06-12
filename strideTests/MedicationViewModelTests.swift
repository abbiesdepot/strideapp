import XCTest
@testable import stride
import FirebaseCore

final class MedicationViewModelTests: XCTestCase {
    
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
        let viewModel = MedicationViewModel()
        XCTAssertTrue(viewModel.medications.isEmpty)
        XCTAssertTrue(viewModel.todayLogs.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testTakeAndUntakeMedicationMockState() {
        let viewModel = MedicationViewModel()
        
        let sampleMed = Medication(
            id: "med_test_101",
            elderlyID: "elder_test_01",
            name: "Aspirin",
            dosage: "100mg",
            frequency: "Once daily",
            scheduleTime: "09:00",
            isEnabled: true,
            createdAt: Date()
        )
        
        XCTAssertEqual(sampleMed.name, "Aspirin")
        XCTAssertEqual(sampleMed.dosage, "100mg")
        XCTAssertEqual(sampleMed.frequency, "Once daily")
        
        let mockLog = MedicationLog(
            id: "log_test_201",
            medicationID: sampleMed.id!,
            elderlyID: sampleMed.elderlyID,
            scheduledTime: Date(),
            confirmedAt: Date(),
            status: "taken"
        )
        
        viewModel.todayLogs = [mockLog]
        XCTAssertEqual(viewModel.todayLogs.count, 1)
        XCTAssertEqual(viewModel.todayLogs.first?.status, "taken")
    }
}
