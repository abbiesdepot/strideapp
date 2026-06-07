import SwiftUI

struct FamilyDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = FamilyDashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.strideBackground.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.elderlyProfiles.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.strideSecondary)
                        Text("No Care Circles")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        Text("You haven't joined any care circles yet.")
                            .foregroundColor(.strideTextSecondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Good day,")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.strideTextSecondary)
                                    
                                    Text(authViewModel.currentUser?.fullName ?? "Family Member")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.stridePrimary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            
                            Text("Daily Overview")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding(.top, 80)
                                
                            } else if let profile = viewModel.elderlyProfile {
                                
                                // JIKA DATA ADA
                                NavigationLink(destination: ElderlyDetailView(profile: profile)) {
                                    ElderlyDashboardCard(
                                        profile: profile,
                                        latestActivity: viewModel.latestActivity,
                                        latestVitalSign: viewModel.latestVitalSign)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 24)
                                
                                //                            ForEach(viewModel.elderlyProfiles) { profile in
                                //                                ElderlyDashboardCard(
                                //                                    profile: profile,
                                //                                    latestActivity: viewModel.latestActivity,
                                //                                    latestVitalSign: viewModel.latestVitalSign)
                                //                                .background(.red)
                                //                                    .padding(.horizontal, 24)
                                //                                    .padding(.bottom, 8)
                                //                                    .overlay(
                                //                                        NavigationLink(destination: DailySummaryView(profile: profile)) {
                                //                                            EmptyView()
                                //                                        }
                                //                                        .opacity(0)
                                //                                    )
                                                            }
                            }
                                .padding(.bottom, 24)
                        }
                    }
                }
                    .navigationBarHidden(true)
            .onAppear {
                if let uid = authViewModel.currentUser?.id {
                    viewModel.fetchDashboardData(userID: uid)
                }
            }
            }
        }
    }

