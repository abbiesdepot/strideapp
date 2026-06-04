import SwiftUI

struct PeopleManagementView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var dashboardVM = CaregiverDashboardViewModel()
    @StateObject private var peopleVM = PeopleViewModel()
    
    @State private var showingInviteCode = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // elderly section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Elderly User")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        
                        if let profile = dashboardVM.elderlyProfile {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(Color.strideTertiary.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .overlay(Image(systemName: "person.fill").foregroundColor(.stridePrimary))
                                
                                VStack(alignment: .leading) {
                                    Text(profile.fullName)
                                        .font(.system(size: 16, weight: .bold))
                                    Text("\(profile.age) years old")
                                        .font(.system(size: 14))
                                        .foregroundColor(.strideTextSecondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.strideCardWhite)
                            .cornerRadius(StrideTheme.cornerRadiusCard)
                        } else {
                            Text("No elderly profile set up.")
                                .foregroundColor(.strideTextSecondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // part yg family
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Family Members")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.stridePrimary)
                            Spacer()
                            if dashboardVM.family != nil {
                                Button(action: { showingInviteCode = true }) {
                                    Text("Invite")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.stridePrimary)
                                }
                            }
                        }
                        
                        if peopleVM.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        } else if peopleVM.familyMembers.isEmpty {
                            Text("No family members yet.")
                                .foregroundColor(.strideTextSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            ForEach(peopleVM.familyMembers) { member in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(member.fullName)
                                            .font(.system(size: 16, weight: .bold))
                                        Text("Family Member")
                                            .font(.system(size: 14))
                                            .foregroundColor(.strideTextSecondary)
                                    }
                                    Spacer()
                                    Button(role: .destructive, action: {
                                        peopleVM.removeFamilyMember(memberDocID: member.memberDocID)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.strideRed)
                                    }
                                }
                                .padding()
                                .background(Color.strideCardWhite)
                                .cornerRadius(StrideTheme.cornerRadiusCard)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 16)
            }
            .background(Color.strideBackground.ignoresSafeArea())
            .navigationTitle("Care Circle")
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
            .sheet(isPresented: $showingInviteCode) {
                if let code = dashboardVM.family?.inviteCode {
                    VStack(spacing: 32) {
                        Text("Invite Family")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text(code)
                            .font(.system(size: 40, weight: .black, design: .monospaced))
                            .tracking(8)
                            .padding(24)
                            .background(Color.strideSecondary.opacity(0.1))
                            .cornerRadius(16)
                        
                        Text("Share this 6-character code with family members so they can join the Care Circle.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .foregroundColor(.strideTextSecondary)
                        
                        Button("Done") {
                            showingInviteCode = false
                        }
                        .font(.system(size: 16, weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.stridePrimary)
                        .foregroundColor(.white)
                        .cornerRadius(StrideTheme.cornerRadiusButton)
                        .padding(.horizontal, 32)
                    }
                    .presentationDetents([.medium])
                }
            }
        }
    }
}
