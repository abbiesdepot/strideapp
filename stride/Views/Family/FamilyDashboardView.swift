import SwiftUI

struct FamilyDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = FamilyDashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // HEADER
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good day,")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.strideTextSecondary)
                            Text(authViewModel.currentUser?.fullName ?? "Family Member")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.stridePrimary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 20))
                                .foregroundColor(.strideRed)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // KONDISI DATA
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 80)
                            
                    } else if viewModel.elderlyProfiles.isEmpty {
                        
                        // JIKA DATA KOSONG
                        VStack(spacing: 20) {
                            Spacer().frame(height: 40)
                            
                            ZStack {
                                Circle()
                                    .fill(Color.stridePrimary.opacity(0.12))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.stridePrimary)
                            }
                            
                            VStack(spacing: 8) {
                                Text("No Care Circles")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.stridePrimary)
                                Text("You haven't joined any care circles yet. Go to your Profile tab to join a Care Circle.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.strideTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                        
                    } else {
                        // JIKA DATA ADA
                        ForEach(viewModel.elderlyProfiles) { profile in
                            FamilyElderlySectionView(profile: profile)
                                .padding(.bottom, 16)
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.strideBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                if let uid = authViewModel.currentUser?.id {
                    viewModel.fetchElderlyProfiles(userID: uid)
                }
            }
        }
    }
}

struct FamilyElderlySectionView: View {
    let profile: ElderlyProfile
    
    @StateObject private var medVM = MedicationViewModel()
    @StateObject private var activityVM = ActivityViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            NavigationLink(destination: ElderlyDetailView(elderlyID: profile.id ?? "", isReadOnly: true)) {
                ElderlyDashboardCard(profile: profile)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 24)
            
            DashboardTodoList(medVM: medVM, activityVM: activityVM, elderlyID: profile.id ?? "", isReadOnly: true)
                .padding(.horizontal, 24)
                .padding(.top, 16)
            
            HStack(spacing: 24) {
                NavigationLink(destination: ElderlyDetailView(elderlyID: profile.id ?? "", isReadOnly: true)) {
                    Text("View Details →")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.strideSecondary)
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: WeeklyHealthTrendView(elderlyID: profile.id ?? "")) {
                    Text("View Trends →")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.strideSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            Divider()
                .padding(.horizontal, 24)
                .padding(.top, 8)
        }
    }
}
