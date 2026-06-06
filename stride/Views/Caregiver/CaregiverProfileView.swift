import SwiftUI

struct CaregiverProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var dashboardVM = CaregiverDashboardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.strideBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        accountSection

                        if let family = dashboardVM.family {
                            inviteCodeSection(family: family)
                        } else {
                            noFamilySection
                        }

                        logOutButton
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if let uid = authViewModel.currentUser?.id {
                dashboardVM.fetchDashboardData(caregiverID: uid)
            }
        }
    }

    // MARK: - Sections

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

                Text("Caregiver")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.stridePrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.stridePrimary.opacity(0.15))
                    .cornerRadius(12)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.strideCardWhite)
        .cornerRadius(StrideTheme.cornerRadiusCard)
        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func inviteCodeSection(family: Family) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Care Circle")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.stridePrimary)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                Text("Invite Code")
                    .font(.system(size: 14))
                    .foregroundColor(.strideTextSecondary)

                Text(family.inviteCode)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.stridePrimary)
                    .kerning(4)

                Text("Share this code with family members so they can join your care circle.")
                    .font(.system(size: 13))
                    .foregroundColor(.strideTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.strideCardWhite)
            .cornerRadius(StrideTheme.cornerRadiusCard)
            .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 2)
            .padding(.horizontal, 20)

            if let profile = dashboardVM.elderlyProfile {
                NavigationLink(destination: ElderlyDetailView(elderlyID: profile.id ?? "")) {
                    Label("Manage Profile", systemImage: "person.crop.rectangle")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.stridePrimary)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.stridePrimary.opacity(0.1))
                        .cornerRadius(StrideTheme.cornerRadiusButton)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var noFamilySection: some View {
        VStack(spacing: 12) {
            Text("Care Circle")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.stridePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

            Text("Set up an elderly profile from the Dashboard to get your invite code.")
                .font(.system(size: 14))
                .foregroundColor(.strideTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
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
