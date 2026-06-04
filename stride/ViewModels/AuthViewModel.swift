import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: StrideUser?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isInCareCircle: Bool = false
    @Published var checkedCareCircle: Bool = false
    
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
    
    func updateProfile(fullName: String, phoneNumber: String, completion: @escaping (Bool) -> Void) {
        guard let uid = currentUser?.id else {
            completion(false)
            return
        }
        isLoading = true
        errorMessage = nil
        
        db.collection("users").document(uid).updateData([
            "fullName": fullName,
            "phoneNumber": phoneNumber
        ]) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                if var updatedUser = self.currentUser {
                    updatedUser.fullName = fullName
                    updatedUser.phoneNumber = phoneNumber
                    self.currentUser = updatedUser
                }
                completion(true)
            }
        }
    }
    
    private func fetchUserRecord(uid: String) {
        isLoading = true
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            self?.isLoading = false
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: StrideUser.self)
                    self?.currentUser = user
                    if user.role.lowercased() == "family_member" {
                        self?.checkCareCircleMembership(uid: uid)
                    } else {
                        self?.isAuthenticated = true
                    }
                } catch {
                    self?.errorMessage = "Error decoding user: \(error.localizedDescription)"
                }
            } else {
                self?.errorMessage = "User record not found."
            }
        }
    }
    
    func checkCareCircleMembership(uid: String) {
        db.collection("familyMembers")
            .whereField("userID", isEqualTo: uid)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let documents = snapshot?.documents, !documents.isEmpty {
                    self.isInCareCircle = true
                } else {
                    self.isInCareCircle = false
                }
                self.checkedCareCircle = true
                self.isAuthenticated = true
            }
    }
}
