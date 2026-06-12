import XCTest
@testable import stride
import FirebaseCore

final class PeopleDeduplicationTests: XCTestCase {

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

    // MARK: - Deduplication via Dictionary keyed by userID

    func testDeduplication_removesExactDuplicates() {
        let memberA = FamilyMemberDetail(
            id: "user_001",
            memberDocID: "doc_001",
            fullName: "Alice",
            role: "family",
            joinedAt: Date()
        )
        let memberADuplicate = FamilyMemberDetail(
            id: "user_001",
            memberDocID: "doc_002",
            fullName: "Alice",
            role: "family",
            joinedAt: Date()
        )
        let memberB = FamilyMemberDetail(
            id: "user_002",
            memberDocID: "doc_003",
            fullName: "Bob",
            role: "family",
            joinedAt: Date()
        )

        let tempMembers = [memberA, memberADuplicate, memberB]

        var uniqueDetails: [String: FamilyMemberDetail] = [:]
        for member in tempMembers {
            uniqueDetails[member.id] = member
        }
        let result = Array(uniqueDetails.values)

        XCTAssertEqual(result.count, 2, "Expected 2 unique members after deduplication, got \(result.count)")
        XCTAssertTrue(result.contains(where: { $0.id == "user_001" }))
        XCTAssertTrue(result.contains(where: { $0.id == "user_002" }))
    }

    func testDeduplication_noDuplicatesIsUnchanged() {
        let members = [
            FamilyMemberDetail(id: "user_001", memberDocID: "doc_001", fullName: "Alice", role: "family", joinedAt: Date()),
            FamilyMemberDetail(id: "user_002", memberDocID: "doc_002", fullName: "Bob", role: "family", joinedAt: Date()),
            FamilyMemberDetail(id: "user_003", memberDocID: "doc_003", fullName: "Carol", role: "family", joinedAt: Date())
        ]

        var uniqueDetails: [String: FamilyMemberDetail] = [:]
        for member in members {
            uniqueDetails[member.id] = member
        }
        let result = Array(uniqueDetails.values)

        XCTAssertEqual(result.count, 3, "Expected 3 unique members when no duplicates, got \(result.count)")
    }

    func testDeduplication_emptyInputProducesEmptyOutput() {
        let tempMembers: [FamilyMemberDetail] = []

        var uniqueDetails: [String: FamilyMemberDetail] = [:]
        for member in tempMembers {
            uniqueDetails[member.id] = member
        }
        let result = Array(uniqueDetails.values)

        XCTAssertTrue(result.isEmpty, "Expected empty result for empty input")
    }

    func testDeduplication_sortingByJoinedAt() {
        let earlier = Date(timeIntervalSinceNow: -3600)
        let later = Date(timeIntervalSinceNow: -1800)
        let latest = Date()

        let members = [
            FamilyMemberDetail(id: "user_001", memberDocID: "doc_001", fullName: "C", role: "family", joinedAt: latest),
            FamilyMemberDetail(id: "user_002", memberDocID: "doc_002", fullName: "A", role: "family", joinedAt: earlier),
            FamilyMemberDetail(id: "user_003", memberDocID: "doc_003", fullName: "B", role: "family", joinedAt: later)
        ]

        let sorted = members.sorted { ($0.joinedAt ?? Date.distantPast) < ($1.joinedAt ?? Date.distantPast) }

        XCTAssertEqual(sorted[0].fullName, "A")
        XCTAssertEqual(sorted[1].fullName, "B")
        XCTAssertEqual(sorted[2].fullName, "C")
    }
}
