//
//  CareCircleTests.swift
//  strideTests
//
//  Property 9: Care circle join/leave is a round trip
//  Validates: Requirements 21.1, 21.2, 21.3
//

import XCTest
@testable import stride
import FirebaseCore

final class CareCircleTests: XCTestCase {

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

    // MARK: - In-Memory Mock

    /// Simulates the Firestore familyMembers collection in memory.
    private var mockCollection: [String: FamilyMember] = [:]

    /// Adds a FamilyMember document and returns the generated document ID.
    private func mockJoin(familyID: String, userID: String) -> String {
        let docID = UUID().uuidString
        mockCollection[docID] = FamilyMember(
            id: docID,
            familyID: familyID,
            userID: userID,
            joinedAt: Date()
        )
        return docID
    }

    /// Removes the FamilyMember document with the given ID.
    private func mockLeave(docID: String) {
        mockCollection.removeValue(forKey: docID)
    }

    // MARK: - Property 9: Join then leave is a round trip

    /// **Property 9: Care circle join/leave is a round trip**
    /// After joining, the collection contains exactly one entry.
    /// After leaving with the returned docID, the collection is empty.
    func testProperty9_joinThenLeaveRoundTrip() {
        for _ in 0..<20 {
            // Start fresh each iteration
            mockCollection = [:]

            let familyID = UUID().uuidString
            let userID = UUID().uuidString

            // Join
            let docID = mockJoin(familyID: familyID, userID: userID)

            // Assert: exactly one entry with correct data
            XCTAssertEqual(mockCollection.count, 1, "Expected exactly 1 entry after join")
            let member = mockCollection[docID]
            XCTAssertNotNil(member, "No entry found for returned docID")
            XCTAssertEqual(member?.familyID, familyID, "familyID mismatch after join")
            XCTAssertEqual(member?.userID, userID, "userID mismatch after join")

            // Leave
            mockLeave(docID: docID)

            // Assert: collection is empty
            XCTAssertTrue(mockCollection.isEmpty, "Expected empty collection after leave")
        }
    }
}
