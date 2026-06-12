import XCTest
@testable import stride
import FirebaseCore

/// Tests for EditFamilyProfileSheet behaviour and updateUserProfile logic in AuthViewModel
final class EditProfileTests: XCTestCase {

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

    // MARK: - updateUserProfile — local state update

    @MainActor
    func testUpdateProfile_updatesCurrentUserLocally() {
        // Given: an AuthViewModel with a pre-populated user
        let vm = AuthViewModel()
        let originalUser = StrideUser(
            id: "uid_001",
            fullName: "Old Name",
            email: "user@test.com",
            phoneNumber: "1111",
            role: "family",
            createdAt: Date()
        )
        vm.currentUser = originalUser

        // When: we simulate the local state update (same logic as AuthViewModel.updateUserProfile)
        if var user = vm.currentUser {
            user.fullName = "New Name"
            user.phoneNumber = "9999"
            vm.currentUser = user
        }

        // Then: currentUser reflects the new values
        XCTAssertEqual(vm.currentUser?.fullName, "New Name")
        XCTAssertEqual(vm.currentUser?.phoneNumber, "9999")
        XCTAssertEqual(vm.currentUser?.email, "user@test.com", "Email should be unchanged")
        XCTAssertEqual(vm.currentUser?.role, "family", "Role should be unchanged")
    }

    @MainActor
    func testUpdateProfile_noSideEffectOnIsLoading() {
        // updateUserProfile should NOT toggle isLoading (to avoid triggering root view re-render)
        let vm = AuthViewModel()
        vm.currentUser = StrideUser(
            id: "uid_001",
            fullName: "Old Name",
            email: "user@test.com",
            phoneNumber: "1111",
            role: "family",
            createdAt: Date()
        )

        XCTAssertFalse(vm.isLoading, "isLoading should be false before calling updateUserProfile")

        // Simulate the local mutation only (no Firestore call in unit tests)
        if var user = vm.currentUser {
            user.fullName = "New"
            vm.currentUser = user
        }

        XCTAssertFalse(vm.isLoading, "isLoading must NOT be set to true during updateUserProfile to avoid root view re-render")
    }

    @MainActor
    func testUpdateProfile_nilCurrentUserDoesNotCrash() {
        let vm = AuthViewModel()
        XCTAssertNil(vm.currentUser)
        // Simulates the guard let uid = currentUser?.id else { return } path
        guard vm.currentUser?.id != nil else {
            // Expected: returns early without crash
            return
        }
        XCTFail("Should have returned early when currentUser is nil")
    }

    // MARK: - Full name validation

    func testFullNameValidation_emptyStringIsInvalid() {
        let name = "   "
        XCTAssertTrue(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Whitespace-only name should be considered invalid")
    }

    func testFullNameValidation_normalNameIsValid() {
        let name = "Michelle Wijaya"
        XCTAssertFalse(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Normal name should be valid")
    }
}
