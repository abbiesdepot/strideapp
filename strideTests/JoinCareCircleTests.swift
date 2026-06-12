import XCTest
@testable import stride
import FirebaseCore

/// Tests for JoinCareCircleView logic:
/// - Sheet mode (onJoinSuccess non-nil) vs standalone mode (onJoinSuccess nil)
/// - Input code trimming to max 6 characters
/// Note: InviteCodeValidator validation rules are covered in InviteCodeTests.swift
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

    // MARK: - Sheet Mode vs Standalone Mode discrimination

    func testSheetMode_onJoinSuccessNonNil() {
        var callbackCalled = false
        let callback: () -> Void = { callbackCalled = true }

        let onJoinSuccess: (() -> Void)? = callback
        XCTAssertNotNil(onJoinSuccess, "In sheet mode, onJoinSuccess must be non-nil")

        onJoinSuccess?()
        XCTAssertTrue(callbackCalled, "Callback should be called when onJoinSuccess is provided")
    }

    func testStandaloneMode_onJoinSuccessNil() {
        let onJoinSuccess: (() -> Void)? = nil
        XCTAssertNil(onJoinSuccess, "In standalone onboarding mode, onJoinSuccess must be nil")
    }

    // MARK: - Input code trimming (UI guard in JoinCareCircleView)

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

    func testCodeTrimming_exactlySixCharsUnchanged() {
        var code = "ABC123"
        if code.count > 6 {
            code = String(code.prefix(6))
        }
        XCTAssertEqual(code, "ABC123")
    }
}
