import XCTest

final class WCSessionPayloadTests: XCTestCase {

    func testProperty4_fallPayloadRoundTrip() {
        for _ in 0..<100 {
            let elderlyID = UUID().uuidString
            let timestamp = Double.random(in: 0...Date().timeIntervalSince1970)

            let payload: [String: Any] = [
                "type": "fall",
                "elderlyID": elderlyID,
                "timestamp": timestamp
            ]
            
            //try to read this back as a string
            let recoveredElderlyID = payload["elderlyID"] as? String
            let recoveredTimestamp = payload["timestamp"] as? Double

            XCTAssertEqual(recoveredElderlyID, elderlyID, "elderlyID mismatch in fall payload")
            XCTAssertEqual(recoveredTimestamp!, timestamp, accuracy: 0.0001, "timestamp mismatch in fall payload")
        }
    }

    func testProperty4_medicationPayloadRoundTrip() {
        for _ in 0..<100 {
            let elderlyID = UUID().uuidString
            let medicationID = UUID().uuidString

            let payload: [String: Any] = [
                "type": "medicationTaken",
                "elderlyID": elderlyID,
                "medicationID": medicationID
            ]

            let recoveredElderlyID = payload["elderlyID"] as? String
            let recoveredMedicationID = payload["medicationID"] as? String

            XCTAssertEqual(recoveredElderlyID, elderlyID, "elderlyID mismatch in medication payload")
            XCTAssertEqual(recoveredMedicationID, medicationID, "medicationID mismatch in medication payload")
        }
    }

    func testProperty4_activityPayloadRoundTrip() {
        for _ in 0..<100 {
            let elderlyID = UUID().uuidString
            let steps = Int.random(in: 0...50000)
            let distanceKM = Double.random(in: 0.0...100.0)

            let payload: [String: Any] = [
                "type": "activity",
                "elderlyID": elderlyID,
                "steps": steps,
                "distanceKM": distanceKM
            ]

            let recoveredElderlyID = payload["elderlyID"] as? String
            let recoveredSteps = payload["steps"] as? Int
            let recoveredDistanceKM = payload["distanceKM"] as? Double

            XCTAssertEqual(recoveredElderlyID, elderlyID, "elderlyID mismatch in activity payload")
            XCTAssertEqual(recoveredSteps, steps, "steps mismatch in activity payload")
            XCTAssertEqual(recoveredDistanceKM!, distanceKM, accuracy: 0.0001, "distanceKM mismatch in activity payload")
        }
    }
}
