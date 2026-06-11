import XCTest
@testable import stride
import FirebaseCore

final class DailyReportViewModelTests: XCTestCase {
    
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
        let viewModel = DailyReportViewModel()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.averageHeartRate, 0)
        XCTAssertEqual(viewModel.averageSpO2, 0)
        XCTAssertEqual(viewModel.averageSteps, 0)
        XCTAssertEqual(viewModel.averageDistance, 0)
        XCTAssertEqual(viewModel.averageIdleMinutes, 0)
        XCTAssertEqual(viewModel.medicationCompliance, 0)
    }

    @MainActor
    func testCalculateVitalsAverages() {
        let viewModel = DailyReportViewModel()
        
        // Setup mock vital signs
        viewModel.vitalSigns = [
            VitalSign(id: "1", elderlyID: "elder_1", heartRate: 80.0, spO2: 98.0, recordedAt: Date()),
            VitalSign(id: "2", elderlyID: "elder_1", heartRate: 90.0, spO2: 96.0, recordedAt: Date()),
            VitalSign(id: "3", elderlyID: "elder_1", heartRate: 70.0, spO2: 97.0, recordedAt: Date())
        ]
        
        viewModel.calculateVitalsAverages()
        
        XCTAssertEqual(viewModel.averageHeartRate, 80.0, accuracy: 0.001)
        XCTAssertEqual(viewModel.averageSpO2, 97.0, accuracy: 0.001)
    }

    @MainActor
    func testCalculateActivityAverages() {
        let viewModel = DailyReportViewModel()
        
        // Setup mock activity logs
        viewModel.activityLogs = [
            ActivityLog(id: "1", elderlyID: "elder_1", stepCount: 1000, distanceKM: 0.8, idleMinutes: 30, recordedAt: Date()),
            ActivityLog(id: "2", elderlyID: "elder_1", stepCount: 2000, distanceKM: 1.6, idleMinutes: 45, recordedAt: Date()),
            ActivityLog(id: "3", elderlyID: "elder_1", stepCount: 3000, distanceKM: 2.4, idleMinutes: 15, recordedAt: Date())
        ]
        
        viewModel.calculateActivityAverages()
        
        XCTAssertEqual(viewModel.averageSteps, 2000.0, accuracy: 0.001)
        XCTAssertEqual(viewModel.averageDistance, 1.6, accuracy: 0.001)
        XCTAssertEqual(viewModel.averageIdleMinutes, 30.0, accuracy: 0.001)
    }

    @MainActor
    func testCalculateMedicationCompliance() {
        let viewModel = DailyReportViewModel()
        
        // Setup mock medication logs
        viewModel.medicationLogs = [
            MedicationLog(id: "1", medicationID: "m1", elderlyID: "elder_1", scheduledTime: Date(), confirmedAt: Date(), status: "taken"),
            MedicationLog(id: "2", medicationID: "m2", elderlyID: "elder_1", scheduledTime: Date(), confirmedAt: nil, status: "missed"),
            MedicationLog(id: "3", medicationID: "m1", elderlyID: "elder_1", scheduledTime: Date(), confirmedAt: Date(), status: "taken"),
            MedicationLog(id: "4", medicationID: "m2", elderlyID: "elder_1", scheduledTime: Date(), confirmedAt: Date(), status: "taken")
        ]
        
        viewModel.calculateMedicationCompliance()
        
        XCTAssertEqual(viewModel.medicationCompliance, 75.0, accuracy: 0.001)
    }
}
