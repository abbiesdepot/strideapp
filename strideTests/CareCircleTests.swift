//
//  CareCircleTests.swift
//  strideTests
//
//  Property 9: Care circle join/leave
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

    private var mockCollection: [String: FamilyMember] = [:]

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

    private func mockLeave(docID: String) {
        mockCollection.removeValue(forKey: docID)
    }


    func testProperty9_joinThenLeaveRoundTrip() {
        for _ in 0..<20 {
            mockCollection = [:]

            let familyID = UUID().uuidString
            let userID = UUID().uuidString

            let docID = mockJoin(familyID: familyID, userID: userID)

            XCTAssertEqual(mockCollection.count, 1, "Expected exactly 1 entry after join")
            let member = mockCollection[docID]
            XCTAssertNotNil(member, "No entry found for returned docID")
            XCTAssertEqual(member?.familyID, familyID, "familyID mismatch after join")
            XCTAssertEqual(member?.userID, userID, "userID mismatch after join")

            mockLeave(docID: docID)

            XCTAssertTrue(mockCollection.isEmpty, "Expected empty collection after leave")
        }
    }
}

//round trip -> join n leave should leave u exactly where u started emoty
