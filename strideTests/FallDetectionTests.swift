import XCTest

private func isFall(gForce: Double, rotationRate: Double) -> Bool {
    return gForce > 3.0 && rotationRate > 2.0
}

final class FallDetectionTests: XCTestCase {
    func testProperty1_dualThresholdTriggersFall() {
        //runs loop 100 times
        for _ in 0..<100 {
            let gForce = Double.random(in: 3.001...20.0)
            let rotationRate = Double.random(in: 2.001...20.0)
            XCTAssertTrue(
                isFall(gForce: gForce, rotationRate: rotationRate),
                "Expected fall detected: gForce=\(gForce), rotationRate=\(rotationRate)"
            )
        }
    }

    func testProperty2_lowGForceNeverTriggers() {
        for _ in 0..<100 {
            let gForce = Double.random(in: 0.0...3.0)
            let rotationRate = Double.random(in: 0.0...20.0)
            XCTAssertFalse(
                isFall(gForce: gForce, rotationRate: rotationRate),
                "Expected no fall: gForce=\(gForce) is at/below threshold"
            )
        }
    }

    func testProperty3_lowRotationRateNeverTriggers() {
        for _ in 0..<100 {
            let rotationRate = Double.random(in: 0.0...2.0)
            let gForce = Double.random(in: 0.0...20.0)
            XCTAssertFalse(
                isFall(gForce: gForce, rotationRate: rotationRate),
                "Expected no fall: rotationRate=\(rotationRate) is at/below threshold"
            )
        }
    }
}
