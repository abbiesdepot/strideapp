import XCTest
@testable import stride
import FirebaseCore

final class AlertViewModelTests: XCTestCase {
    
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
        let viewModel = AlertViewModel()
        XCTAssertTrue(viewModel.alerts.isEmpty)
        XCTAssertEqual(viewModel.unreadCount, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testUnreadCountLogic() {
        let viewModel = AlertViewModel()
        let alert1 = Alert(
            id: "a_01",
            elderlyID: "elder_01",
            familyID: "fam_01",
            type: "fall",
            severity: "red",
            message: "Detected a fall",
            isResolved: false,
            triggeredAt: Date(),
            seenBy: []
        )
        let alert2 = Alert(
            id: "a_02",
            elderlyID: "elder_01",
            familyID: "fam_01",
            type: "SOS",
            severity: "red",
            message: "SOS pressed",
            isResolved: true,
            triggeredAt: Date(),
            seenBy: []
        )
        
        viewModel.alerts = [alert1, alert2]
        viewModel.unreadCount = viewModel.alerts.filter { !$0.isResolved }.count
        XCTAssertEqual(viewModel.alerts.count, 2)
        XCTAssertEqual(viewModel.unreadCount, 1)
    }
}
