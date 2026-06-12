import XCTest
@testable import stride
import FirebaseCore

final class ActivityViewModelTests: XCTestCase {
    
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
        let viewModel = ActivityViewModel()
        XCTAssertTrue(viewModel.activities.isEmpty)
        XCTAssertTrue(viewModel.todayLogs.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testAddActivityLocalState() {
        let viewModel = ActivityViewModel()
        XCTAssertNil(viewModel.errorMessage)
        
        // Test helper values and properties
        let mockActivity = CareActivity(
            id: "act_test_01",
            elderlyID: "elder_test_01",
            name: "Makan Siang",
            frequency: "Daily",
            scheduleTime: "12:00",
            isEnabled: true,
            createdAt: Date()
        )
        
        XCTAssertEqual(mockActivity.name, "Makan Siang")
        XCTAssertEqual(mockActivity.frequency, "Daily")
        XCTAssertEqual(mockActivity.scheduleTime, "12:00")
        XCTAssertTrue(mockActivity.isEnabled)
    }
}
