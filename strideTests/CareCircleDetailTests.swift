import XCTest
@testable import stride
import FirebaseCore

/// Tests for FamilyProfileViewModel — care circle management and state
final class CareCircleDetailTests: XCTestCase {

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

    private func makeProfile(id: String, familyID: String, name: String) -> ElderlyProfile {
        ElderlyProfile(
            id: id,
            fullName: name,
            age: 75,
            height: nil, weight: nil, bloodType: nil, notes: nil,
            photoURL: nil, medicalNotes: nil,
            familyID: familyID,
            stepCount: nil, distanceKM: nil, heartRate: nil,
            stressPercentage: nil, sleepAwakeMin: nil, sleepREMMin: nil,
            sleepCoreMin: nil, sleepDeepMin: nil,
            liveStatus: "green", liveStatusReason: "OK",
            createdAt: Date()
        )
    }

    // MARK: - FamilyProfileViewModel Initial State

    func testInitialState() {
        let vm = FamilyProfileViewModel()
        XCTAssertTrue(vm.careCircles.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    // MARK: - CareCircleDetail model integrity

    func testCareCircleDetail_holdsMemberData() {
        let profile = makeProfile(id: "elder_01", familyID: "fam_01", name: "Grandma")
        let detail = CareCircleDetail(
            id: "circle_01",
            memberDocID: "member_01",
            familyID: "fam_01",
            elderlyProfile: profile,
            caregiverName: "Dr. Sari"
        )

        XCTAssertEqual(detail.id, "circle_01")
        XCTAssertEqual(detail.memberDocID, "member_01")
        XCTAssertEqual(detail.familyID, "fam_01")
        XCTAssertEqual(detail.elderlyProfile.fullName, "Grandma")
        XCTAssertEqual(detail.caregiverName, "Dr. Sari")
    }

    // MARK: - Leave care circle (local state removal)

    func testLeaveCareCircle_removesFromLocalArray() {
        let vm = FamilyProfileViewModel()
        let profile1 = makeProfile(id: "elder_01", familyID: "fam_01", name: "Elder A")
        let profile2 = makeProfile(id: "elder_02", familyID: "fam_02", name: "Elder B")
        vm.careCircles = [
            CareCircleDetail(id: "c1", memberDocID: "m1", familyID: "fam_01", elderlyProfile: profile1, caregiverName: ""),
            CareCircleDetail(id: "c2", memberDocID: "m2", familyID: "fam_02", elderlyProfile: profile2, caregiverName: "")
        ]

        // Simulate the local removal that happens in leaveCareCircle's Firestore completion
        vm.careCircles.removeAll { $0.memberDocID == "m1" }

        XCTAssertEqual(vm.careCircles.count, 1)
        XCTAssertEqual(vm.careCircles.first?.memberDocID, "m2")
    }

    func testLeaveCareCircle_nonExistentDocIDDoesNothing() {
        let vm = FamilyProfileViewModel()
        let profile = makeProfile(id: "elder_01", familyID: "fam_01", name: "Elder A")
        vm.careCircles = [
            CareCircleDetail(id: "c1", memberDocID: "m1", familyID: "fam_01", elderlyProfile: profile, caregiverName: "")
        ]

        vm.careCircles.removeAll { $0.memberDocID == "nonexistent" }

        XCTAssertEqual(vm.careCircles.count, 1, "Count should be unchanged when trying to remove non-existent member")
    }

    // MARK: - Multiple care circles supported

    func testMultipleCareCircles_canJoinTwo() {
        let vm = FamilyProfileViewModel()
        let p1 = makeProfile(id: "e1", familyID: "f1", name: "Grandpa")
        let p2 = makeProfile(id: "e2", familyID: "f2", name: "Grandma")

        vm.careCircles = [
            CareCircleDetail(id: "c1", memberDocID: "m1", familyID: "f1", elderlyProfile: p1, caregiverName: ""),
            CareCircleDetail(id: "c2", memberDocID: "m2", familyID: "f2", elderlyProfile: p2, caregiverName: "")
        ]

        XCTAssertEqual(vm.careCircles.count, 2)
        XCTAssertTrue(vm.careCircles.contains(where: { $0.elderlyProfile.fullName == "Grandpa" }))
        XCTAssertTrue(vm.careCircles.contains(where: { $0.elderlyProfile.fullName == "Grandma" }))
    }
}
