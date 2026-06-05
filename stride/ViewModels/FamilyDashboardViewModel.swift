import Foundation
import FirebaseFirestore
import Combine

@MainActor
class FamilyDashboardViewModel: ObservableObject {
    @Published var elderlyProfiles: [ElderlyProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var latestActivity: ActivityLog?
    @Published var latestVitalSign: VitalSign?
    
    private var db = Firestore.firestore()
    
    func fetchElderlyProfiles(userID: String) {
        isLoading = true
        // fetch from familyMembers where userID == userID
        db.collection("familyMembers")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.isLoading = false
                    return
                }
                
                let familyIDs = documents.compactMap { try? $0.data(as: FamilyMember.self).familyID }
                
                if familyIDs.isEmpty {
                    self.isLoading = false
                    return
                }
                
                // fetch the elderly profiles (w the assumption 1 elderly per family)
                self.db.collection("elderlyProfiles")
                    .whereField("familyID", in: familyIDs)
                    .addSnapshotListener { snapshot, error in
                        self.isLoading = false
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            return
                        }
                        
                        guard let documents = snapshot?.documents else { return }
                        self.elderlyProfiles = documents.compactMap { try? $0.data(as: ElderlyProfile.self) }
                    }
            }
    }
    
    func joinCareCircle(inviteCode: String, userID: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        let upperCode = inviteCode.uppercased()
        
        db.collection("family")
            .whereField("inviteCode", isEqualTo: upperCode)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    completion(false, error.localizedDescription)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    self.isLoading = false
                    completion(false, "Invalid invite code. Please try again.")
                    return
                }
                
                guard let family = try? document.data(as: Family.self), let familyID = family.id else {
                    self.isLoading = false
                    completion(false, "Error parsing family data.")
                    return
                }
                
                // add ke familyMembers
                let newMember = FamilyMember(familyID: familyID, userID: userID, joinedAt: Date())
                
                do {
                    try self.db.collection("familyMembers").addDocument(from: newMember) { error in
                        self.isLoading = false
                        if let error = error {
                            completion(false, error.localizedDescription)
                        } else {
                            // refresh the dashboard
                            self.fetchElderlyProfiles(userID: userID)
                            completion(true, nil)
                        }
                    }
                } catch {
                    self.isLoading = false
                    completion(false, error.localizedDescription)
                }
            }
    }
}
