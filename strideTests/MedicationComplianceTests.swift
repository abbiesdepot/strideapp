import XCTest
@testable import stride
import FirebaseCore

final class MedicationComplianceTests: XCTestCase {

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

    private func makeLogs(taken: Int, missed: Int) -> [MedicationLog] {
        let takenLogs = (0..<taken).map { _ in
            MedicationLog(
                id: UUID().uuidString,
                medicationID: UUID().uuidString,
                elderlyID: UUID().uuidString,
                scheduledTime: Date(),
                confirmedAt: Date(),
                status: "taken"
            )
        }
        let missedLogs = (0..<missed).map { _ in
            MedicationLog(
                id: UUID().uuidString,
                medicationID: UUID().uuidString,
                elderlyID: UUID().uuidString,
                scheduledTime: Date(),
                confirmedAt: nil,
                status: "missed"
            )
        }
        return (takenLogs + missedLogs).shuffled()
    }

    func testProperty7_complianceAlwaysInRange() {
        for _ in 0..<100 {
            let takenCount = Int.random(in: 0...20)
            let missedCount = Int.random(in: 0...20)
            let logs = makeLogs(taken: takenCount, missed: missedCount)

            let result = MedicationComplianceCalculator.calculateCompliance(logs: logs)

            XCTAssertGreaterThanOrEqual(result, 0.0, "Compliance \(result) is below 0")
            XCTAssertLessThanOrEqual(result, 100.0, "Compliance \(result) exceeds 100")

            // taken count never exceeds total
            let total = takenCount + missedCount
            if total > 0 {
                let expectedMax = Double(takenCount) / Double(total) * 100.0
                XCTAssertEqual(result, expectedMax, accuracy: 0.001)
            }
        }
    }

    func testProperty7_allTakenIs100() {
        for count in [1, 5, 10, 20] {
            let logs = makeLogs(taken: count, missed: 0)
            let result = MedicationComplianceCalculator.calculateCompliance(logs: logs)
            XCTAssertEqual(result, 100.0, accuracy: 0.001, "All-taken should be 100%, got \(result)")
        }
    }

    func testProperty7_emptyLogsIsZero() {
        let result = MedicationComplianceCalculator.calculateCompliance(logs: [])
        XCTAssertEqual(result, 0.0, accuracy: 0.001, "Empty logs should be 0%, got \(result)")
    }
}
