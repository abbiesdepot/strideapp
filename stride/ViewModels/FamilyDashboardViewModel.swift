import Foundation
import FirebaseFirestore
import Combine

@MainActor
class FamilyDashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var elderlyProfile: ElderlyProfile?
    @Published var latestActivity: ActivityLog?
    @Published var latestVitalSign: VitalSign?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    // MARK: - Data Fetching
    /// Mengambil data dashboard secara lengkap berdasarkan userID
    func fetchDashboardData(userID: String) {
        self.isLoading = true
        
        // 1. Cari familyID berdasarkan userID dari koleksi familyMembers
        db.collection("familyMembers")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let familyID = snapshot?.documents.first?.data()["familyID"] as? String else {
                    self.isLoading = false
                    return
                }
                
                // 2. Ambil profil lansia berdasarkan familyID
                self.db.collection("elderlyProfiles")
                    .whereField("familyID", isEqualTo: familyID)
                    .addSnapshotListener { snapshot, error in
                        if let doc = snapshot?.documents.first {
                            let profile = try? doc.data(as: ElderlyProfile.self)
                            self.elderlyProfile = profile
                            
                            // 3. Tarik data pendukung menggunakan elderlyID
                            if let elderlyID = profile?.id {
                                self.fetchLatestActivity(elderlyID: elderlyID)
                                self.fetchLatestVitalSign(elderlyID: elderlyID)
                            }
                        }
                        self.isLoading = false
                    }
            }
    }
    
    private func fetchLatestActivity(elderlyID: String) {
        db.collection("activityLogs")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .order(by: "recordedAt", descending: true)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, _ in
                self?.latestActivity = snapshot?.documents.first.flatMap { try? $0.data(as: ActivityLog.self) }
            }
    }
    
    private func fetchLatestVitalSign(elderlyID: String) {
        db.collection("vitalSigns")
            .whereField("elderlyID", isEqualTo: elderlyID)
            .order(by: "recordedAt", descending: true)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, _ in
                self?.latestVitalSign = snapshot?.documents.first.flatMap { try? $0.data(as: VitalSign.self) }
            }
    }
    
    // MARK: - Logic Business
    /// Fungsi untuk bergabung ke lingkaran perawatan menggunakan invite code
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
                
                guard let document = snapshot?.documents.first,
                      let family = try? document.data(as: Family.self),
                      let familyID = family.id else {
                    self.isLoading = false
                    completion(false, "Invalid invite code.")
                    return
                }
                
                let newMember = FamilyMember(familyID: familyID, userID: userID, joinedAt: Date())
                
                do {
                    try self.db.collection("familyMembers").addDocument(from: newMember) { error in
                        if let error = error {
                            self.isLoading = false
                            completion(false, error.localizedDescription)
                        } else {
                            // Refresh data setelah berhasil join
                            self.fetchDashboardData(userID: userID)
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
