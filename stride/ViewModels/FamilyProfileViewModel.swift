import Foundation
import FirebaseFirestore
import Combine

class FamilyProfileViewModel: ObservableObject {
    @Published var careCircles: [CareCircleDetail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    struct CareCircleDetail: Identifiable {
        let id: String // familyMemberDocID
        let familyID: String
        let elderlyProfile: ElderlyProfile
        let caregiverName: String
    }
    
    func fetchCareCircles(userID: String) {
        isLoading = true
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("familyMembers")
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    self.careCircles = []
                    return
                }
                
                if documents.isEmpty {
                    self.isLoading = false
                    self.careCircles = []
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                var tempDetails: [CareCircleDetail] = []
                
                for document in documents {
                    guard let member = try? document.data(as: FamilyMember.self), let memberDocID = member.id else { continue }
                    
                    dispatchGroup.enter()
                    
                    self.db.collection("family").document(member.familyID).getDocument { familyDoc, familyErr in
                        guard let familyDoc = familyDoc, familyDoc.exists,
                              let family = try? familyDoc.data(as: Family.self) else {
                            dispatchGroup.leave()
                            return
                        }
                        
                        self.db.collection("elderlyProfiles").document(family.elderlyID).getDocument { elderlyDoc, elderlyErr in
                            guard let elderlyDoc = elderlyDoc, elderlyDoc.exists,
                                  let elderly = try? elderlyDoc.data(as: ElderlyProfile.self) else {
                                dispatchGroup.leave()
                                return
                            }
                            
                            self.db.collection("users").document(family.caregiverID).getDocument { caregiverDoc, caregiverErr in
                                var caregiverName = "Caregiver"
                                if let caregiverDoc = caregiverDoc, caregiverDoc.exists,
                                   let caregiver = try? caregiverDoc.data(as: StrideUser.self) {
                                    caregiverName = caregiver.fullName
                                }
                                
                                let detail = CareCircleDetail(
                                    id: memberDocID,
                                    familyID: member.familyID,
                                    elderlyProfile: elderly,
                                    caregiverName: caregiverName
                                )
                                tempDetails.append(detail)
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.isLoading = false
                    self.careCircles = tempDetails
                }
            }
    }
    
    func leaveCareCircle(memberDocID: String, completion: @escaping (Bool) -> Void) {
        db.collection("familyMembers").document(memberDocID).delete() { error in
            completion(error == nil)
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
