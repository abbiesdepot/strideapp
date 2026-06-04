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
                            Text(greetingMessage)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.strideTextSecondary)
                            
                            Text(authViewModel.currentUser?.fullName ?? "Caregiver")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.stridePrimary)
                        }
                        Spacer()
                        
                        // We will remove the redundant logout button from dashboard since it is in the Profile tab now
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 50)
                    } else if let profile = viewModel.elderlyProfile {
                        VStack(spacing: 24) {
                            // Status Card
                            ElderlyDashboardCard(
                                profile: profile,
                                vitals: viewModel.latestVitalSign,
                                medicationCompliance: viewModel.medicationComplianceText,
                                lastActiveText: viewModel.lastActiveText
                            )
                            
                            // Medications Schedule List
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's Medications")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.stridePrimary)
                                
                                if viewModel.activeMedications.isEmpty {
                                    Text("No medications scheduled. Add from elderly details.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.strideTextSecondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color.strideCardWhite)
                                        .cornerRadius(StrideTheme.cornerRadiusCard)
                                } else {
                                    ForEach(viewModel.activeMedications) { medication in
                                        let log = viewModel.todayMedicationLogs.first(where: { $0.medicationID == medication.id })
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(medication.name)
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.strideTextPrimary)
                                                Text(medication.dosage)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.strideTextSecondary)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text(medication.scheduleTime)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.strideTextSecondary)
                                                
                                                if let log = log {
                                                    if log.status.lowercased() == "taken" {
                                                        Text("taken ✓")
                                                            .font(.system(size: 12, weight: .bold))
                                                            .foregroundColor(.strideGreen)
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(Color.strideGreen.opacity(0.15))
                                                            .cornerRadius(8)
                                                    } else {
                                                        Text("missed ✗")
                                                            .font(.system(size: 12, weight: .bold))
                                                            .foregroundColor(.strideRed)
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(Color.strideRed.opacity(0.15))
                                                            .cornerRadius(8)
                                                    }
                                                } else {
                                                    Text("pending")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.strideNeutral)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(Color.strideNeutral.opacity(0.15))
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color.strideCardWhite)
                                        .cornerRadius(StrideTheme.cornerRadiusCard)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    } else {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 80))
                                .foregroundColor(.strideSecondary)
                            
                            Text("No elderly profile yet")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.stridePrimary)
                            
                            Text("Set up an elderly profile to start monitoring health.")
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
                                    .background(Color.strideSecondary)
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
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning,"
        } else if hour < 17 {
            return "Good afternoon,"
        } else {
            return "Good evening,"
        }
    }
}

#Preview {
    CaregiverDashboardView()
        .environmentObject(AuthViewModel())
}
