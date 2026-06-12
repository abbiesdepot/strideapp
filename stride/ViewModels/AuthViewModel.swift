import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: StrideUser?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    /// Whether the current family_member user belongs to at least one care circle.
    @Published var isInCareCircle: Bool = false
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.fetchUserRecord(uid: user.uid)
            } else {
                self?.isAuthenticated = false
                self?.currentUser = nil
            }
        }
    }
    
    func register(fullName: String, email: String, phone: String, role: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            
            let user = StrideUser(id: uid, fullName: fullName, email: email, phoneNumber: phone, role: role, createdAt: Date())
            
            do {
                try self.db.collection("users").document(uid).setData(from: user) { error in
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.currentUser = user
                        self.isAuthenticated = true
                    }
                }
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
                return
            }
            // StateDidChangeListener bakal fetch the user record
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func updateUserProfile(fullName: String, phoneNumber: String, completion: @escaping (Bool) -> Void) {
        guard let uid = currentUser?.id else {
            completion(false)
            return
        }
        
        db.collection("users").document(uid).updateData([
            "fullName": fullName,
            "phoneNumber": phoneNumber
        ]) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    if var user = self?.currentUser {
                        user.fullName = fullName
                        user.phoneNumber = phoneNumber
                        self?.currentUser = user
                    }
                    completion(true)
                }
            }
        }
    }



    func checkCareCircleMembership(uid: String) {
        db.collection("familyMembers")
            .whereField("userID", isEqualTo: uid)
            .getDocuments { [weak self] snapshot, _ in
                DispatchQueue.main.async {
                    self?.isInCareCircle = !(snapshot?.documents.isEmpty ?? true)
                }
            }
    }
    
    private func fetchUserRecord(uid: String) {
        isLoading = true
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            self?.isLoading = false
            if let document = document, document.exists {
                do {
                    self?.currentUser = try document.data(as: StrideUser.self)
                    self?.isAuthenticated = true
                } catch {
                    self?.errorMessage = "Error decoding user: \(error.localizedDescription)"
                }
            } else {
                self?.errorMessage = "User record not found."
            }
        }
    }
}
