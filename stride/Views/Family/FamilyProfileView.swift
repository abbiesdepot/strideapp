import SwiftUI

struct FamilyProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = FamilyProfileViewModel()
    
    @State private var showingEditProfile = false
    @State private var editName = ""
    @State private var editPhone = ""
    
    @State private var showingJoinSheet = false
    @State private var circleToLeave: FamilyProfileViewModel.CareCircleDetail? = nil
    @State private var showingLeaveAlert = false
    
    @State private var toastMessage: String? = nil
    @State private var showToast = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // SECTION 1: ACCOUNT INFO
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.strideSecondary.opacity(0.2))
                            .frame(width: 90, height: 90)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.strideSecondary)
                            )
                        
                        Text(authViewModel.currentUser?.fullName ?? "Family Member")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        
                        Text(authViewModel.currentUser?.email ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.strideTextSecondary)
                        
                        Text("Family Member")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.strideSecondary)
                            .cornerRadius(12)
                        
                        Button(action: {
                            editName = authViewModel.currentUser?.fullName ?? ""
                            editPhone = authViewModel.currentUser?.phoneNumber ?? ""
                            showingEditProfile = true
                        }) {
                            Text("Edit Profile")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.stridePrimary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.stridePrimary.opacity(0.1))
                                .cornerRadius(StrideTheme.cornerRadiusButton)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.strideCardWhite)
                    .cornerRadius(StrideTheme.cornerRadiusCard)
                    .padding(.horizontal, 24)
                    
                    // SECTION 2: MY CARE CIRCLES
                    VStack(alignment: .leading, spacing: 12) {
                        Text("My Care Circles")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.stridePrimary)
                            .padding(.horizontal, 24)
                        
                        if profileVM.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        } else if profileVM.careCircles.isEmpty {
                            VStack(spacing: 12) {
                                Text("You aren't in any Care Circles yet.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.strideTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.strideCardWhite)
                            .cornerRadius(StrideTheme.cornerRadiusCard)
                            .padding(.horizontal, 24)
                        } else {
                            ForEach(profileVM.careCircles) { detail in
                                VStack(alignment: .leading, spacing: 16) {
                                    NavigationLink(destination: DailySummaryView(profile: detail.elderlyProfile)) {
                                        HStack(spacing: 16) {
                                            Circle()
                                                .fill(Color.strideTertiary.opacity(0.2))
                                                .frame(width: 44, height: 44)
                                                .overlay(Image(systemName: "person.fill").foregroundColor(.stridePrimary))
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack(spacing: 8) {
                                                    Text(detail.elderlyProfile.fullName)
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(.strideTextPrimary)
                                                    
                                                    Circle()
                                                        .fill(detail.elderlyProfile.liveStatus.lowercased() == "green" ? Color.strideGreen : (detail.elderlyProfile.liveStatus.lowercased() == "yellow" ? Color.strideYellow : Color.strideRed))
                                                        .frame(width: 8, height: 8)
                                                }
                                                
                                                Text("Caregiver: \(detail.caregiverName)")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.strideTextSecondary)
                                            }
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14))
                                                .foregroundColor(.strideNeutral)
                                        }
                                    }
                                    
                                    Button(action: {
                                        circleToLeave = detail
                                        showingLeaveAlert = true
                                    }) {
                                        Text("Leave Care Circle")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.strideRed)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(Color.strideRed.opacity(0.08))
                                            .cornerRadius(StrideTheme.cornerRadiusButton)
                                    }
                                }
                                .padding()
                                .background(Color.strideCardWhite)
                                .cornerRadius(StrideTheme.cornerRadiusCard)
                                .padding(.horizontal, 24)
                            }
                        }
                    }
                    
                    // SECTION 3: APP & ACTIONS
                    VStack(spacing: 16) {
                        Button(action: {
                            showingJoinSheet = true
                        }) {
                            Text("Join Another Care Circle")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.strideSecondary)
                                .cornerRadius(StrideTheme.cornerRadiusButton)
                        }
                        
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            Text("Log Out")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.strideTextSecondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.strideNeutral.opacity(0.15))
                                .cornerRadius(StrideTheme.cornerRadiusButton)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
            .background(Color.strideBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEditProfile) {
                editProfileSheet
            }
            .sheet(isPresented: $showingJoinSheet) {
                NavigationStack {
                    JoinCareCircleView()
                        .environmentObject(authViewModel)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") { showingJoinSheet = false }
                            }
                        }
                }
            }
            .confirmationDialog(
                "Leave Care Circle?",
                isPresented: $showingLeaveAlert,
                titleVisibility: .visible
            ) {
                Button("Leave Circle", role: .destructive) {
                    if let detail = circleToLeave {
                        profileVM.leaveCareCircle(memberDocID: detail.id) { success in
                            if success {
                                showToast(message: "Left Care Circle successfully.")
                                // Recheck membership to trigger JoinCareCircleView redirection if empty
                                if let uid = authViewModel.currentUser?.id {
                                    authViewModel.checkCareCircleMembership(uid: uid)
                                }
                            }
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to leave \(circleToLeave?.elderlyProfile.fullName ?? "this")'s Care Circle? You will no longer receive updates or alerts.")
            }
            .overlay(
                VStack {
                    if showToast, let msg = toastMessage {
                        Spacer()
                        Text(msg)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 24)
                    }
                }
                .animation(.spring(), value: showToast)
            )
            .onAppear {
                if let uid = authViewModel.currentUser?.id {
                    profileVM.fetchCareCircles(userID: uid)
                }
            }
        }
    }
    
    private var editProfileSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Info")) {
                    TextField("Full Name", text: $editName)
                    TextField("Phone Number", text: $editPhone)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingEditProfile = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        authViewModel.updateProfile(fullName: editName, phoneNumber: editPhone) { success in
                            if success {
                                showingEditProfile = false
                                showToast(message: "Profile updated successfully!")
                            }
                        }
                    }
                    .disabled(editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func showToast(message: String) {
        toastMessage = message
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
}

#Preview {
    FamilyProfileView()
        .environmentObject(AuthViewModel())
}
