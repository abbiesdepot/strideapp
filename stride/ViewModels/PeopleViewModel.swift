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
                    self.familyMembers = tempMembers.sorted { ($0.joinedAt ?? Date.distantPast) < ($1.joinedAt ?? Date.distantPast) }
                }
            }
    }
    
    func removeFamilyMember(memberDocID: String) {
        db.collection("familyMembers").document(memberDocID).delete()
    }
}
