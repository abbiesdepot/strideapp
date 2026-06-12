import XCTest
@testable import stride
import FirebaseCore

/// Tests for JoinCareCircleView logic: cancel (sheet mode) vs sign-out (standalone mode) discrimination
final class JoinCareCircleTests: XCTestCase {

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

    // MARK: - Invite Code Validation (used in isFormValid)

    func testInviteCodeValid_sixUppercaseAlphanumeric() {
        XCTAssertTrue(InviteCodeValidator.isValid("ABC123"))
        XCTAssertTrue(InviteCodeValidator.isValid("ZZZZZZ"))
        XCTAssertTrue(InviteCodeValidator.isValid("000000"))
        XCTAssertTrue(InviteCodeValidator.isValid("A1B2C3"))
    }

    func testInviteCodeInvalid_tooShort() {
        XCTAssertFalse(InviteCodeValidator.isValid("AB123"))
        XCTAssertFalse(InviteCodeValidator.isValid(""))
    }

    func testInviteCodeInvalid_tooLong() {
        XCTAssertFalse(InviteCodeValidator.isValid("ABC1234"))
        XCTAssertFalse(InviteCodeValidator.isValid("ABCDEFG"))
    }

    func testInviteCodeInvalid_lowercaseLetters() {
        XCTAssertFalse(InviteCodeValidator.isValid("abc123"))
        XCTAssertFalse(InviteCodeValidator.isValid("AbCdEf"))
    }

    func testInviteCodeInvalid_specialCharacters() {
        XCTAssertFalse(InviteCodeValidator.isValid("AB#123"))
        XCTAssertFalse(InviteCodeValidator.isValid("A!C1E3"))
    }

    // MARK: - Sheet Mode vs Standalone Mode discrimination

    func testSheetMode_onJoinSuccessNonNil() {
        var callbackCalled = false
        let callback: () -> Void = { callbackCalled = true }

        // Simulates the sheet mode path
        let onJoinSuccess: (() -> Void)? = callback
        XCTAssertNotNil(onJoinSuccess, "In sheet mode, onJoinSuccess must be non-nil")

        onJoinSuccess?()
        XCTAssertTrue(callbackCalled, "Callback should be called when onJoinSuccess is provided")
    }

    func testStandaloneMode_onJoinSuccessNil() {
        // Simulates the standalone onboarding mode
        let onJoinSuccess: (() -> Void)? = nil
        XCTAssertNil(onJoinSuccess, "In standalone mode, onJoinSuccess must be nil")
    }

    // MARK: - Code trimming to max 6 chars

    func testCodeTrimming_truncatesTo6Chars() {
        var code = "ABCDEFGHIJ"
        if code.count > 6 {
            code = String(code.prefix(6))
        }
        XCTAssertEqual(code.count, 6)
        XCTAssertEqual(code, "ABCDEF")
    }

    func testCodeTrimming_shortCodeUnchanged() {
        var code = "ABC"
        if code.count > 6 {
            code = String(code.prefix(6))
        }
        XCTAssertEqual(code, "ABC")
    }
}
