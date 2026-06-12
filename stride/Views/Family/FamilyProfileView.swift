import SwiftUI

struct FamilyProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = FamilyProfileViewModel()

    @State private var showingJoinSheet = false
    @State private var showingEditSheet = false
    @State private var leaveTarget: CareCircleDetail? = nil
    @State private var showLeaveConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.strideBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        accountSection
                        careCirclesSection
                        logOutButton
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if let uid = authViewModel.currentUser?.id {
                    profileVM.fetchCareCircles(userID: uid)
                }
            }
            .sheet(isPresented: $showingJoinSheet, onDismiss: {
                if let uid = authViewModel.currentUser?.id {
                    profileVM.fetchCareCircles(userID: uid)
                }
            }) {
                NavigationStack {
                    JoinCareCircleView(onJoinSuccess: {
                        showingJoinSheet = false
                        if let uid = authViewModel.currentUser?.id {
                            profileVM.fetchCareCircles(userID: uid)
                        }
                    })
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditFamilyProfileSheet(authViewModel: authViewModel)
            }
            .confirmationDialog(
                "Leave Care Circle",
                isPresented: $showLeaveConfirm,
                titleVisibility: .visible
            ) {
                Button("Leave", role: .destructive) {
                    guard let target = leaveTarget else { return }
                    profileVM.leaveCareCircle(memberDocID: target.memberDocID) {
                        if profileVM.careCircles.isEmpty {
                            if let uid = authViewModel.currentUser?.id {
                                authViewModel.checkCareCircleMembership(uid: uid)
                            }
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will lose access to this care circle's alerts and updates.")
            }
        }
    }

    private var accountSection: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color.strideTertiary.opacity(0.3))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.stridePrimary)
                )

            VStack(spacing: 4) {
                Text(authViewModel.currentUser?.fullName ?? "—")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.stridePrimary)

                Text(authViewModel.currentUser?.email ?? "—")
                    .font(.system(size: 14))
                    .foregroundColor(.strideTextSecondary)

                Text("Family Member")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.strideSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.strideSecondary.opacity(0.15))
                    .cornerRadius(12)
            }

            Button("Edit Profile") {
                showingEditSheet = true
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.strideSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
        .padding(.horizontal, 20)
    }

    private var careCirclesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Care Circles")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.stridePrimary)
                .padding(.horizontal, 20)

            if profileVM.isLoading {
                ProgressView().padding(.horizontal, 20)
            } else if profileVM.careCircles.isEmpty {
                Text("You aren't in any Care Circles yet.")
                    .font(.system(size: 14))
                    .foregroundColor(.strideTextSecondary)
                    .padding(.horizontal, 20)
            } else {
                ForEach(profileVM.careCircles) { circle in
                    NavigationLink(destination: ElderlyDetailView(elderlyID: circle.elderlyProfile.id ?? "", isReadOnly: true)) {
                        careCircleRow(circle)
                    }
                    .padding(.horizontal, 20)
                }
            }

            Button(action: { showingJoinSheet = true }) {
                Label("Join Another Care Circle", systemImage: "plus.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.strideSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.strideSecondary.opacity(0.1))
                    .cornerRadius(StrideTheme.cornerRadiusButton)
            }
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private func careCircleRow(_ circle: CareCircleDetail) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.strideTertiary.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.stridePrimary)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(circle.elderlyProfile.fullName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.stridePrimary)

                HStack(spacing: 6) {
                    LiveStatusBadge(status: circle.elderlyProfile.liveStatus)
                }
            }

            Spacer()

            Button("Leave") {
                leaveTarget = circle
                showLeaveConfirm = true
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.strideRed)
        }
        .padding(14)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
    }

    private var logOutButton: some View {
        Button(action: { authViewModel.logout() }) {
            Text("Log Out")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.strideRed)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.strideRed.opacity(0.1))
                .cornerRadius(StrideTheme.cornerRadiusButton)
        }
        .padding(.horizontal, 20)
    }
}

struct EditFamilyProfileSheet: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName: String = ""
    @State private var phoneNumber: String = ""
    @State private var isSaving = false
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Info")) {
                    TextField("Full Name", text: $fullName)
                        .disabled(isSaving)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .disabled(isSaving)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        isSaving = true
                        authViewModel.updateUserProfile(fullName: fullName, phoneNumber: phoneNumber) { success in
                            isSaving = false
                            if success {
                                dismiss()
                            } else {
                                showingError = true
                            }
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
            }
            .alert("Failed to Update Profile", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authViewModel.errorMessage ?? "An unknown error occurred.")
            }
            .onAppear {
                if let user = authViewModel.currentUser {
                    fullName = user.fullName
                    phoneNumber = user.phoneNumber
                }
            }
        }
    }
}


