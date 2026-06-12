import Foundation
import FirebaseFirestore
import Combine

struct FamilyMemberDetail: Identifiable {
    let id: String
    let memberDocID: String // the ID of the familyMembers document (to delete it later)
    let fullName: String
    let role: String
    let joinedAt: Date?
}

@MainActor
class PeopleViewModel: ObservableObject {
    @Published var familyMembers: [FamilyMemberDetail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    func fetchFamilyMembers(familyID: String) {
        isLoading = true
        
        db.collection("familyMembers")
            .whereField("familyID", isEqualTo: familyID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                // for each member, we need to fetch their user profile to get the name
                let dispatchGroup = DispatchGroup()
                var tempMembers: [FamilyMemberDetail] = []
                
                for document in documents {
                    guard let member = try? document.data(as: FamilyMember.self), let memberDocID = member.id else { continue }
                    
                    dispatchGroup.enter()
                    self.db.collection("users").document(member.userID).getDocument { userDoc, userError in
                        if let userDoc = userDoc, let user = try? userDoc.data(as: StrideUser.self) {
                            let detail = FamilyMemberDetail(
                                id: user.id ?? UUID().uuidString,
                                memberDocID: memberDocID,
                                fullName: user.fullName,
                                role: user.role,
                                joinedAt: member.joinedAt
                            )
                            tempMembers.append(detail)
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.isLoading = false
                    
                    // Deduplicate by userID (which is detail.id)
                    var uniqueDetails: [String: FamilyMemberDetail] = [:]
                    for member in tempMembers {
                        uniqueDetails[member.id] = member
                    }
                    
                    self.familyMembers = Array(uniqueDetails.values).sorted { ($0.joinedAt ?? Date.distantPast) < ($1.joinedAt ?? Date.distantPast) }
                }
            }
    }
    
    func removeFamilyMember(memberDocID: String) {
        db.collection("familyMembers").document(memberDocID).delete()
    }
    
    func addFamilyMemberByEmail(email: String, familyID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        db.collection("users")
            .whereField("email", isEqualTo: cleanedEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let userDoc = snapshot?.documents.first else {
                    let notFoundError = NSError(domain: "PeopleViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Email family belum terdaftar."])
                    completion(.failure(notFoundError))
                    return
                }
                
                let userID = userDoc.documentID
                
                // Cek apakah user sudah terdaftar di keluarga ini
                self.db.collection("familyMembers")
                    .whereField("familyID", isEqualTo: familyID)
                    .whereField("userID", isEqualTo: userID)
                    .getDocuments { memberSnapshot, memberError in
                        if let memberError = memberError {
                            completion(.failure(memberError))
                            return
                        }
                        
                        if let memberDocs = memberSnapshot?.documents, !memberDocs.isEmpty {
                            let duplicateError = NSError(domain: "PeopleViewModel", code: 409, userInfo: [NSLocalizedDescriptionKey: "Anggota keluarga ini sudah bergabung."])
                            completion(.failure(duplicateError))
                            return
                        }
                        
                        // Tambahkan ke familyMembers
                        let newMemberData: [String: Any] = [
                            "familyID": familyID,
                            "userID": userID,
                            "joinedAt": Timestamp(date: Date())
                        ]
                        
                        self.db.collection("familyMembers").addDocument(data: newMemberData) { addError in
                            if let addError = addError {
                                completion(.failure(addError))
                            } else {
                                completion(.success(()))
                            }
                        }
                    }
            }
    }
}
