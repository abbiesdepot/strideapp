import Foundation
import FirebaseFirestore
import Combine

struct CareCircleDetail: Identifiable {
    let id: String // familyMember document ID
    let memberDocID: String
    let familyID: String
    let elderlyProfile: ElderlyProfile
    let caregiverName: String
}

class FamilyProfileViewModel: ObservableObject {
    @Published var careCircles: [CareCircleDetail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var db = Firestore.firestore()


    private var membersListener: ListenerRegistration?
    private var profilesListener: ListenerRegistration?

    func fetchCareCircles(userID: String) {
        isLoading = true
        membersListener?.remove()
        profilesListener?.remove()
        
        membersListener = db.collection("familyMembers")
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }

                let members = snapshot?.documents
                    .compactMap { doc -> (String, FamilyMember)? in
                        guard let m = try? doc.data(as: FamilyMember.self) else { return nil }
                        return (doc.documentID, m)
                    } ?? []

                guard !members.isEmpty else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.careCircles = []
                    }
                    return
                }

                let familyIDs = members.map { $0.1.familyID }
                self.resolveProfiles(members: members, familyIDs: familyIDs)
            }
    }

    func leaveCareCircle(memberDocID: String, completion: @escaping () -> Void) {
        db.collection("familyMembers").document(memberDocID).delete { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.careCircles.removeAll { $0.memberDocID == memberDocID }
                    completion()
                }
            }
        }
    }

    private func resolveProfiles(members: [(String, FamilyMember)], familyIDs: [String]) {
        profilesListener?.remove()
        profilesListener = db.collection("elderlyProfiles")
            .whereField("familyID", in: familyIDs)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }

                let profiles = snapshot?.documents.compactMap { try? $0.data(as: ElderlyProfile.self) } ?? []

                var details: [CareCircleDetail] = []
                for (docID, member) in members {
                    guard let profile = profiles.first(where: { $0.familyID == member.familyID }) else { continue }
                    details.append(CareCircleDetail(
                        id: docID,
                        memberDocID: docID,
                        familyID: member.familyID,
                        elderlyProfile: profile,
                        caregiverName: ""   // caregiver name can be resolved separately if needed
                    ))
                }

                DispatchQueue.main.async {
                    self.isLoading = false
                    self.careCircles = details
                }
            }
    }

    deinit {
        membersListener?.remove()
        profilesListener?.remove()
    }
}

