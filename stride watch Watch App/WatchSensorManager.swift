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
    @Published var fallCountdown: Int = 15
    @Published var sensorsActive: Bool = false
    @Published var demoMode: Bool = false {
        didSet {
            if demoMode {
                startDemoSensorFeed()
            } else {
                stopDemoSensorFeed()
            }
        }
    }

    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    private var session: WCSession?
    private var countdownTimer: Timer?
    private var demoTimer: Timer?
    private var demoTick: Double = 0.0
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
            sensorsActive = false
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

        sensorsActive = true
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
            self.fallCountdown = 15
            self.startCountdown()
        }
        let payload: [String: Any] = [
            "type": "fall",
            "timestamp": Date().timeIntervalSince1970
        ]
        sendWatchConnectivityMessage(payload: payload)
    }

    func cancelFallAlert() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        fallCountdown = 15
        isFallDetected = false
        if demoMode {
            currentGForce = 0.0
            currentRotationRate = 0.0
        }
        let payload: [String: Any] = ["type": "cancelFall"]
        sendWatchConnectivityMessage(payload: payload)
    }

    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                if self.fallCountdown > 0 {
                    self.fallCountdown -= 1
                } else {
                    self.countdownTimer?.invalidate()
                    self.countdownTimer = nil
                }
            }
        }
    }

    private func startDemoSensorFeed() {
        stopDemoSensorFeed()
        demoTick = 0.0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self, self.demoMode else { return }
            self.demoTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
                guard let self, self.demoMode, !self.isFallDetected else {
                    self?.stopDemoSensorFeed()
                    return
                }
                self.demoTick += 0.08

                let t = min(self.demoTick / 2.5, 1.0)
                let eased = t * t * t
                self.currentGForce = eased * 4.5
                self.currentRotationRate = eased * 3.5

                self.checkFallThresholds()
            }
        }
    }

    private func stopDemoSensorFeed() {
        demoTimer?.invalidate()
        demoTimer = nil
        demoTick = 0.0
        if !isFallDetected {
            currentGForce = 0.0
            currentRotationRate = 0.0
        }
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
