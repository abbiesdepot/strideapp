import SwiftUI

struct WeeklyHealthTrendView: View {
    let elderlyID: String
    @StateObject private var viewModel = DailyReportViewModel()
    
    var body: some View {
        ZStack {
            Color.strideBackground.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // 1. CARDIOVASCULAR HEALTH CARD
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "heart.text.square.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.strideRed)
                                Text("Cardiovascular Averages")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.stridePrimary)
                            }
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Heart Rate")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.strideTextSecondary)
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        Text(viewModel.averageHeartRate > 0 ? String(format: "%.0f", viewModel.averageHeartRate) : "—")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.stridePrimary)
                                        Text("BPM")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.strideTextSecondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("SpO2 (Oxygen)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.strideTextSecondary)
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        Text(viewModel.averageSpO2 > 0 ? String(format: "%.1f", viewModel.averageSpO2) : "—")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.stridePrimary)
                                        Text("%")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.strideTextSecondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Text("Normal heart rate ranges between 60 to 100 BPM. Normal blood oxygen levels are usually 95% or higher.")
                                .font(.system(size: 12))
                                .foregroundColor(.strideTextSecondary)
                                .italic()
                        }
                        .padding(20)
                        .background(Color.strideCardWhite)
                        .cornerRadius(StrideTheme.cornerRadiusCard)
                        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
                        .padding(.horizontal, 24)
                        
                        // 2. PHYSICAL ACTIVITY CARD
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "figure.walk.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.strideSecondary)
                                Text("Activity Averages")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.stridePrimary)
                            }
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Daily Steps")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.strideTextSecondary)
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        Text(viewModel.averageSteps > 0 ? String(format: "%.0f", viewModel.averageSteps) : "—")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.stridePrimary)
                                        Text("steps")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.strideTextSecondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Daily Distance")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.strideTextSecondary)
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        Text(viewModel.averageDistance > 0 ? String(format: "%.2f", viewModel.averageDistance) : "—")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.stridePrimary)
                                        Text("KM")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.strideTextSecondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Idle Time")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.strideTextSecondary)
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        Text(viewModel.averageIdleMinutes > 0 ? String(format: "%.0f", viewModel.averageIdleMinutes) : "—")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.stridePrimary)
                                        Text("min")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.strideTextSecondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(20)
                        .background(Color.strideCardWhite)
                        .cornerRadius(StrideTheme.cornerRadiusCard)
                        .shadow(color: StrideTheme.shadowColor, radius: StrideTheme.shadowRadius, x: 0, y: 4)
                        .padding(.horizontal, 24)
                        
                        // HISTORICAL LOGS RECORD
                        if !viewModel.activityLogs.isEmpty || !viewModel.vitalSigns.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Recent Vitals History")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.stridePrimary)
                                    .padding(.horizontal, 24)
                                
                                ForEach(viewModel.vitalSigns.prefix(5)) { sign in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Heart Rate: \(Int(sign.heartRate)) BPM")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.stridePrimary)
                                            Text("SpO2: \(Int(sign.spO2))%")
                                                .font(.system(size: 14))
                                                .foregroundColor(.strideTextSecondary)
                                        }
                                        Spacer()
                                        Text(sign.recordedAt, style: .date)
                                            .font(.system(size: 12))
                                            .foregroundColor(.strideTextSecondary)
                                    }
                                    .padding(16)
                                    .background(Color.strideCardWhite)
                                    .cornerRadius(12)
                                    .shadow(color: StrideTheme.shadowColor, radius: 2, x: 0, y: 1)
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                        
                        Spacer().frame(height: 20)
                    }
                }
            }
        }
        .navigationTitle("Daily Report")
        .onAppear {
            viewModel.fetchDailyReport(elderlyID: elderlyID)
        }
    }
}
