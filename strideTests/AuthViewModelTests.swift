import XCTest
@testable import stride
import FirebaseCore

final class AuthViewModelTests: XCTestCase {
    
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
        let viewModel = AuthViewModel()
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.currentUser)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isInCareCircle)
    }
    
    @MainActor
    func testMockSetUser() {
        let viewModel = AuthViewModel()
        let mockUser = StrideUser(id: "test_user_id", fullName: "Jane Doe", email: "jane@example.com", phoneNumber: "12345", role: "family", createdAt: Date())
        viewModel.currentUser = mockUser
        viewModel.isAuthenticated = true
        
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.currentUser?.fullName, "Jane Doe")
        XCTAssertEqual(viewModel.currentUser?.role, "family")
    }
}
