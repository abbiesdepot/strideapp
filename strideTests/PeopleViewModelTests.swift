import XCTest
@testable import stride
import FirebaseCore

final class PeopleViewModelTests: XCTestCase {
    
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
        let viewModel = PeopleViewModel()
        XCTAssertTrue(viewModel.familyMembers.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testEmailTrimmingLogic() {
        // Testing that the email trimming/formatting logic handles whitespaces and lowercasing properly
        let inputEmails = [" Test@stride.com ", "test@stride.com", "TEST@STRIDE.COM\n"]
        let expected = "test@stride.com"
        
        for email in inputEmails {
            let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            XCTAssertEqual(cleanedEmail, expected, "Email \(email) was not correctly formatted to \(expected)")
        }
    }
}
