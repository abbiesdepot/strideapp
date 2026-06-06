import XCTest
@testable import stride
import FirebaseCore

final class AlertSeenByTests: XCTestCase {
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

    func applyMarkAllAsSeen(alerts: inout [Alert], userID: String) {
        for i in alerts.indices {
            if alerts[i].seenBy?.contains(userID) != true {
                if alerts[i].seenBy == nil {
                    alerts[i].seenBy = [userID]
                } else {
                    alerts[i].seenBy!.append(userID)
                }
            }
        }
    }

    private func randomAlerts(count: Int, possiblyContaining userID: String? = nil) -> [Alert] {
        let types = ["SOS", "fall", "missed_med", "inactivity"]
        let severities = ["red", "yellow"]

        return (0..<count).map { _ in
            let existingCount = Int.random(in: 0...3)
            var seenBy: [String] = (0..<existingCount).map { _ in UUID().uuidString }
            if let uid = userID, Bool.random() {
                seenBy.append(uid)
            }

            return Alert(
                id: UUID().uuidString,
                elderlyID: UUID().uuidString,
                familyID: UUID().uuidString,
                type: types.randomElement()!,
                severity: severities.randomElement()!,
                message: "Test alert",
                isResolved: Bool.random(),
                triggeredAt: Date(),
                seenBy: seenBy.isEmpty ? nil : seenBy
            )
        }
    }

    func testProperty8_seenByIdempotent() {
        for _ in 0..<100 {
            let userID = UUID().uuidString
            let alertCount = Int.random(in: 0...10)

            let baseAlerts = randomAlerts(count: alertCount, possiblyContaining: userID)

            var afterOne = baseAlerts
            applyMarkAllAsSeen(alerts: &afterOne, userID: userID)

            var afterTwo = afterOne
            applyMarkAllAsSeen(alerts: &afterTwo, userID: userID)

            for i in afterOne.indices {
                XCTAssertEqual(
                    afterOne[i].seenBy,
                    afterTwo[i].seenBy,
                    "Idempotency violated at index \(i): first=\(String(describing: afterOne[i].seenBy)), second=\(String(describing: afterTwo[i].seenBy))"
                )
            }
        }
    }

    func testProperty8_seenByExactlyOnce() {
        for _ in 0..<100 {
            let userID = UUID().uuidString
            let alertCount = Int.random(in: 0...10)

            var alerts = randomAlerts(count: alertCount, possiblyContaining: nil)

            applyMarkAllAsSeen(alerts: &alerts, userID: userID)

            for alert in alerts {
                let seenBy = alert.seenBy ?? []

                XCTAssertTrue(
                    seenBy.contains(userID),
                    "userID \(userID) not found in seenBy after markAllAsSeen"
                )

                let occurrences = seenBy.filter { $0 == userID }.count
                XCTAssertEqual(
                    occurrences,
                    1,
                    "userID \(userID) appears \(occurrences) times in seenBy — expected exactly 1"
                )
            }
        }
    }
}
