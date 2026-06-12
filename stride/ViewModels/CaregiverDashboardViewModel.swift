import Foundation
import FirebaseFirestore
import Combine

@MainActor
class CaregiverDashboardViewModel: ObservableObject {
    @Published var elderlyProfile: ElderlyProfile?
    @Published var family: Family?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    func fetchDashboardData(caregiverID: String) {
        isLoading = true
        db.collection("family")
            .whereField("caregiverID", isEqualTo: caregiverID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    self.isLoading = false
                    // no family set up yet
                    return
                }
                
                do {
                    self.family = try document.data(as: Family.self)
                    if let elderlyID = self.family?.elderlyID {
                        self.listenToElderlyProfile(elderlyID: elderlyID)
                    }
                } catch {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
    }
    
    private func listenToElderlyProfile(elderlyID: String) {
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("elderlyProfiles").document(elderlyID)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = documentSnapshot else {
                    self.errorMessage = "Elderly profile not found."
                    return
                }
                
                do {
                    self.elderlyProfile = try document.data(as: ElderlyProfile.self)
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
    }
    
    func createElderlyProfile(caregiverID: String, fullName: String, age: Int, height: Double?, weight: Double?, bloodType: String?, medicalNotes: String, notes: String?, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        let newElderly = ElderlyProfile(
            fullName: fullName,
            age: age,
            height: height,
            weight: weight,
            bloodType: bloodType,
            notes: notes,
            photoURL: nil,
            medicalNotes: medicalNotes,
            familyID: nil, // bakal be set after Family creation
            stepCount: nil,
            distanceKM: nil,
            heartRate: nil,
            stressPercentage: nil,
            sleepAwakeMin: nil,
            sleepREMMin: nil,
            sleepCoreMin: nil,
            sleepDeepMin: nil,
            liveStatus: "green",
            liveStatusReason: "Setup complete",
            createdAt: Date()
        )
        
        do {
            let ref = try db.collection("elderlyProfiles").addDocument(from: newElderly) { error in
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
            }
            
            let elderlyID = ref.documentID
            let inviteCode = String((0..<6).map{ _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
            
            let newFamily = Family(
                caregiverID: caregiverID,
                elderlyID: elderlyID,
                inviteCode: inviteCode,
                createdAt: Date()
            )
            
            // Pre-generate the family document reference so its ID is known before the closure runs
            let familyDocRef = db.collection("family").document()
            let generatedFamilyID = familyDocRef.documentID
            
            try familyDocRef.setData(from: newFamily) { error in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    // update elderly profile w familyID using the pre-generated ID
                    self.db.collection("elderlyProfiles").document(elderlyID).updateData([
                        "familyID": generatedFamilyID
                    ])
                    completion(true)
                }
            }

        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            completion(false)
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
