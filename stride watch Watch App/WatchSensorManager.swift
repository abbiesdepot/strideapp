import Foundation
import CoreMotion
import Combine
import WatchConnectivity

class WatchSensorManager: NSObject, ObservableObject {


    @Published var currentGForce: Double = 0.0
    @Published var currentRotationRate: Double = 0.0
    @Published var isFallDetected: Bool = false
    @Published var liveStatus: String = "green"
    @Published var liveStatusReason: String = ""
    @Published var stepCount: Int = 0
    @Published var distanceKM: Double = 0.0


    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    private var session: WCSession?


    static func isFall(gForce: Double, rotationRate: Double) -> Bool {
        return gForce > 3.0 && rotationRate > 2.0
    }


    override init() {
        super.init()
        setupWatchConnectivity()
    }


    func setupSensorMonitoring() {
        guard motionManager.isAccelerometerAvailable && motionManager.isGyroAvailable else {
            print("WatchSensorManager: Accelerometer or gyroscope unavailable on this device — skipping sensor setup.")
            return
        }

        if #available(watchOS 7.2, *) {
            if CMFallDetectionManager.isAvailable {
                let fallManager = CMFallDetectionManager()
                
                if fallManager.authorizationStatus != .authorized {
                    fallManager.requestAuthorization { status in
                        switch status {
                        case .authorized:
                            print("Fall detection authorized by elderly user.")
                        case .denied, .restricted, .notDetermined:
                            print("Fall detection not authorized: \(status)")
                        @unknown default:
                            break
                        }
                    }
                }
            }
        }

        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.gyroUpdateInterval = 0.1

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            self.currentGForce = sqrt(x * x + y * y + z * z)
            self.checkFallThresholds()
        }

        motionManager.startGyroUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            let x = data.rotationRate.x
            let y = data.rotationRate.y
            let z = data.rotationRate.z
            self.currentRotationRate = sqrt(x * x + y * y + z * z)
        }

        startPedometerUpdates()
    }

    private func checkFallThresholds() {
        guard !isFallDetected else { return }
        if WatchSensorManager.isFall(gForce: currentGForce, rotationRate: currentRotationRate) {
            triggerFallSequence()
        }
    }

    func triggerFallSequence() {
        DispatchQueue.main.async {
            self.isFallDetected = true
        }
        let payload: [String: Any] = [
            "type": "fall",
            "timestamp": Date().timeIntervalSince1970
        ]
        sendWatchConnectivityMessage(payload: payload)
    }

    func cancelFallAlert() {
        isFallDetected = false
        let payload: [String: Any] = ["type": "cancelFall"]
        sendWatchConnectivityMessage(payload: payload)
    }


    func sendSOS() {
        let payload: [String: Any] = [
            "type": "sos",
            "timestamp": Date().timeIntervalSince1970
        ]
        sendWatchConnectivityMessage(payload: payload)
    }

    func sendSOSCancel() {
        let payload: [String: Any] = ["type": "cancelSOS"]
        sendWatchConnectivityMessage(payload: payload)
    }


    func recordMedicationTaken(medicationID: String) {
        let payload: [String: Any] = [
            "type": "medicationTaken",
            "medicationID": medicationID,
            "timestamp": Date().timeIntervalSince1970
        ]
        sendWatchConnectivityMessage(payload: payload)
    }


    private func startPedometerUpdates() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        pedometer.startUpdates(from: startOfDay) { [weak self] data, _ in
            guard let self, let data else { return }
            DispatchQueue.main.async {
                self.stepCount = data.numberOfSteps.intValue
                if let distance = data.distance {
                    self.distanceKM = distance.doubleValue / 1000.0
                }
            }
        }
    }


    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    func sendWatchConnectivityMessage(payload: [String: Any]) {
        guard let session else { return }
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil, errorHandler: nil)
        } else {
            session.transferUserInfo(payload)
        }
    }
}


extension WatchSensorManager: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}
}
