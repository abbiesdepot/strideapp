import XCTest
@testable import stride
import FirebaseCore

final class InviteCodeTests: XCTestCase {

    private let validChars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

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

    func testProperty5_validCodesPass() {
        for _ in 0..<100 {
            let code = String((0..<6).map { _ in validChars.randomElement()! })
            XCTAssertTrue(
                InviteCodeValidator.isValid(code),
                "Expected valid: \(code)"
            )
        }
    }

    func testProperty5_invalidCodesFail() {
        for _ in 0..<100 {
            if Bool.random() {
                let length = Bool.random() ? Int.random(in: 0...5) : Int.random(in: 7...12)
                let code = String((0..<length).map { _ in validChars.randomElement()! })
                XCTAssertFalse(
                    InviteCodeValidator.isValid(code),
                    "Expected invalid (wrong length \(length)): \(code)"
                )
            } else {
                let invalidChars = Array("abcdefghijklmnopqrstuvwxyz!@#$%^&*()")
                var chars = (0..<5).map { _ in validChars.randomElement()! }
                chars.append(invalidChars.randomElement()!)
                chars.shuffle()
                let code = String(chars)
                XCTAssertFalse(
                    InviteCodeValidator.isValid(code),
                    "Expected invalid (bad char): \(code)"
                )
            }
        }
    }

    func testProperty6_generatedCodesAreValid() {
        for _ in 0..<100 {
            let generated = String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
            XCTAssertTrue(
                InviteCodeValidator.isValid(generated),
                "Generated code failed validation: \(generated)"
            )
        }
    }
}
