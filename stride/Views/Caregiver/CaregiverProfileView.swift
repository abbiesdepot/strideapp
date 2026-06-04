import SwiftUI

struct CaregiverProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var dashboardVM = CaregiverDashboardViewModel()
    @StateObject private var peopleVM = PeopleViewModel()
    
    @State private var showingEditProfile = false
    @State private var editName = ""
    @State private var editPhone = ""
    
    @State private var showingSetupWizard = false
    @State private var memberToRemove: FamilyMemberDetail? = nil
    @State private var showingRemoveAlert = false
    
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
                        
                        Text(authViewModel.currentUser?.fullName ?? "Caregiver")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        
                        Text(authViewModel.currentUser?.email ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.strideTextSecondary)
                        
                        Text("Caregiver")
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
                    
                    // SECTION 2: MY ELDERLY
                    VStack(alignment: .leading, spacing: 12) {
                        Text("My Elderly")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.stridePrimary)
                            .padding(.horizontal, 24)
                        
                        if let profile = dashboardVM.elderlyProfile {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(Color.strideTertiary.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                        .overlay(Image(systemName: "person.fill").foregroundColor(.stridePrimary))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(profile.fullName)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.strideTextPrimary)
                                        
                                        HStack(spacing: 8) {
                                            Text("\(profile.age) years old")
                                                .font(.system(size: 14))
                                                .foregroundColor(.strideTextSecondary)
                                            
                                            Circle()
                                                .fill(profile.liveStatus.lowercased() == "green" ? Color.strideGreen : (profile.liveStatus.lowercased() == "yellow" ? Color.strideYellow : Color.strideRed))
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    Spacer()
                                }
                                
                                NavigationLink(destination: ElderlyDetailView(elderlyID: profile.id ?? "")) {
                                    Text("Manage Profile")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.stridePrimary)
                                        .cornerRadius(StrideTheme.cornerRadiusButton)
                                }
                            }
                            .padding()
                            .background(Color.strideCardWhite)
                            .cornerRadius(StrideTheme.cornerRadiusCard)
                            .padding(.horizontal, 24)
                        } else {
                            VStack(spacing: 12) {
                                Text("No elderly profile connected yet.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.strideTextSecondary)
                                
                                Button(action: {
                                    showingSetupWizard = true
                                }) {
                                    Text("Add Elderly Profile")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color.stridePrimary)
                                        .cornerRadius(StrideTheme.cornerRadiusButton)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.strideCardWhite)
                            .cornerRadius(StrideTheme.cornerRadiusCard)
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // SECTION 3: CARE CIRCLE
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Care Circle")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.stridePrimary)
                            .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            if let family = dashboardVM.family {
                                Text("Family Members")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.strideTextPrimary)
                                
                                if peopleVM.isLoading {
                                    ProgressView().frame(maxWidth: .infinity)
                                } else if peopleVM.familyMembers.isEmpty {
                                    Text("No family members have joined yet.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.strideTextSecondary)
                                } else {
                                    ForEach(peopleVM.familyMembers) { member in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(member.fullName)
                                                    .font(.system(size: 14, weight: .semibold))
                                                Text("Joined \(formatDate(member.joinedAt))")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.strideTextSecondary)
                                            }
                                            Spacer()
                                            Button(action: {
                                                memberToRemove = member
                                                showingRemoveAlert = true
                                            }) {
                                                Text("Remove")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.strideRed)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.strideRed.opacity(0.1))
                                                    .cornerRadius(8)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                
                                Divider().padding(.vertical, 8)
                                
                                Text("Invite Code")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.strideTextPrimary)
                                
                                HStack(spacing: 12) {
                                    Text(family.inviteCode)
                                        .font(.system(size: 24, weight: .black, design: .monospaced))
                                        .tracking(4)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.strideBackground)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.strideNeutral.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    Button(action: {
                                        UIPasteboard.general.string = family.inviteCode
                                        showToast(message: "Invite code copied!")
                                    }) {
                                        Image(systemName: "doc.on.doc.fill")
                                            .foregroundColor(.white)
                                            .padding(14)
                                            .background(Color.strideSecondary)
                                            .cornerRadius(8)
                                    }
                                    
                                    ShareLink(item: family.inviteCode, subject: Text("Join Stride Care Circle"), message: Text("Use this code to join my Care Circle on Stride: \(family.inviteCode)")) {
                                        Image(systemName: "square.and.arrow.up.fill")
                                            .foregroundColor(.white)
                                            .padding(14)
                                            .background(Color.stridePrimary)
                                            .cornerRadius(8)
                                    }
                                }
                                
                                Divider().padding(.vertical, 8)
                                
                                NavigationLink(destination: PeopleManagementView()) {
                                    Text("Manage Care Circle Members →")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.stridePrimary)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            } else {
                                Text("Set up an elderly profile to generate a care circle invite code.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.strideTextSecondary)
                            }
                        }
                        .padding()
                        .background(Color.strideCardWhite)
                        .cornerRadius(StrideTheme.cornerRadiusCard)
                        .padding(.horizontal, 24)
                    }
                    
                    // SECTION 4: APP & LOGOUT
                    VStack(spacing: 12) {
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            Text("Log Out")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.strideRed)
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
            .sheet(isPresented: $showingSetupWizard) {
                ElderlySetupView(viewModel: dashboardVM)
            }
            .confirmationDialog(
                "Are you sure you want to remove \(memberToRemove?.fullName ?? "this family member")?",
                isPresented: $showingRemoveAlert,
                titleVisibility: .visible
            ) {
                Button("Remove Member", role: .destructive) {
                    if let docID = memberToRemove?.memberDocID {
                        peopleVM.removeFamilyMember(memberDocID: docID)
                        showToast(message: "Family member removed.")
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("They will no longer receive alerts or updates for this elderly person.")
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
                    dashboardVM.fetchDashboardData(caregiverID: uid)
                }
            }
            .onChange(of: dashboardVM.family?.id) { familyID in
                if let familyID = familyID {
                    peopleVM.fetchFamilyMembers(familyID: familyID)
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
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
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
    CaregiverProfileView()
        .environmentObject(AuthViewModel())
}
