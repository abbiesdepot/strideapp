import SwiftUI

struct CaregiverDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = CaregiverDashboardViewModel()
    @State private var showingSetup = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good day,")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.strideTextSecondary)
                            
                            Text(authViewModel.currentUser?.fullName ?? "Caregiver")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.stridePrimary)
                        }
                        Spacer()
                        
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.strideRed)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 50)
                    } else if let profile = viewModel.elderlyProfile {
                        ElderlyDashboardCard(profile: profile)
                            .padding(.horizontal, 24)
                    } else {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.strideSecondary)
                            
                            Text("No Elderly Profile")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.stridePrimary)
                            
                            Text("Set up a profile to start monitoring your loved one's health.")
                                .font(.system(size: 16))
                                .foregroundColor(.strideTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Button(action: {
                                showingSetup = true
                            }) {
                                Text("+ Add Elderly Profile")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.stridePrimary)
                                    .foregroundColor(.white)
                                    .cornerRadius(StrideTheme.cornerRadiusButton)
                            }
                            .padding(.top, 16)
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 40)
                    }
                }
            }
            .background(Color.strideBackground.ignoresSafeArea())
#if os(iOS)
            .navigationBarHidden(true)
#endif
            .sheet(isPresented: $showingSetup) {
                ElderlySetupView(viewModel: viewModel)
            }
            .onAppear {
                if let uid = authViewModel.currentUser?.id {
                    viewModel.fetchDashboardData(caregiverID: uid)
                }
            }
        }
    }
}

#Preview {
    CaregiverDashboardView()
        .environmentObject(AuthViewModel())
}
