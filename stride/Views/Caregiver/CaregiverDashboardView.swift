import SwiftUI

struct CaregiverDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = CaregiverDashboardViewModel()
    @State private var showingSetup = false

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
                            Text(authViewModel.currentUser?.fullName ?? "Caregiver")
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

                    } else if let profile = viewModel.elderlyProfile {

                        // JIKA DATA ADA
                        NavigationLink(destination: ElderlyDetailView(profile: profile)) {
                            ElderlyDashboardCard(profile: profile)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 24)

                    } else {

                        // JIKA DATA KOSONG
                        VStack(spacing: 20) {
                            Spacer().frame(height: 40)

                            ZStack {
                                Circle()
                                    .fill(Color.stridePrimary.opacity(0.12))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 44))
                                    .foregroundColor(.stridePrimary)
                            }

                            VStack(spacing: 8) {
                                Text("No Elderly Profile")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.stridePrimary)
                                Text("Set up a profile to start monitoring your loved one's health.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.strideTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }

                            Spacer().frame(height: 8)

                            Button(action: {
                                showingSetup = true
                            }) {
                                Text("+ Add Elderly Profile")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.stridePrimary)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.strideBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
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
