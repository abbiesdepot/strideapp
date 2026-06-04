import SwiftUI
import Charts

struct WeeklyHealthChartsView: View {
    @StateObject private var historyVM = HealthHistoryViewModel()
    let elderlyID: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if historyVM.isLoading {
                    ProgressView().padding(.top, 50)
                } else {
                    
                    // CHART 1: STEP COUNT & FALL MARKERS (LINE CHART)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step Counts & Falls")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        
                        if historyVM.activityLogs.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 40))
                                    .foregroundColor(.strideNeutral.opacity(0.5))
                                Text("No step count data recorded in the last 7 days.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.strideTextSecondary)
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.strideCardWhite)
                            .cornerRadius(StrideTheme.cornerRadiusCard)
                        } else {
                            Chart {
                                ForEach(historyVM.activityLogs) { log in
                                    LineMark(
                                        x: .value("Day", log.recordedAt, unit: .day),
                                        y: .value("Steps", log.stepCount)
                                    )
                                    .foregroundStyle(Color.strideSecondary)
                                    .interpolationMethod(.catmullRom)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    
                                    PointMark(
                                        x: .value("Day", log.recordedAt, unit: .day),
                                        y: .value("Steps", log.stepCount)
                                    )
                                    .foregroundStyle(Color.strideSecondary)
                                }
                                
                                // Fall events red dot markers
                                ForEach(historyVM.fallAlerts) { alert in
                                    RuleMark(
                                        x: .value("Fall Day", alert.triggeredAt, unit: .day)
                                    )
                                    .foregroundStyle(Color.strideRed.opacity(0.3))
                                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                    
                                    PointMark(
                                        x: .value("Fall Day", alert.triggeredAt, unit: .day),
                                        y: .value("Steps", 0)
                                    )
                                    .foregroundStyle(Color.strideRed)
                                    .symbolSize(120)
                                    .annotation(position: .top) {
                                        VStack(spacing: 2) {
                                            Image(systemName: "figure.fall")
                                                .foregroundColor(.strideRed)
                                                .font(.system(size: 14, weight: .bold))
                                            Text("Fall")
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundColor(.strideRed)
                                        }
                                        .padding(4)
                                        .background(Color.strideCardWhite)
                                        .cornerRadius(4)
                                        .shadow(color: .black.opacity(0.1), radius: 2)
                                    }
                                }
                            }
                            .frame(height: 220)
                            .padding()
                            .background(Color.strideCardWhite)
                            .cornerRadius(StrideTheme.cornerRadiusCard)
                        }
                    }
                    
                    // CHART 2: MEDICATION COMPLIANCE % (BAR CHART)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Medication Compliance")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.stridePrimary)
                        
                        Chart {
                            ForEach(historyVM.medicationCompliance) { item in
                                BarMark(
                                    x: .value("Day", item.date, unit: .day),
                                    y: .value("Compliance %", item.compliancePercentage)
                                )
                                .foregroundStyle(
                                    item.compliancePercentage >= 80 ? Color.strideGreen :
                                    (item.compliancePercentage >= 50 ? Color.strideYellow : Color.strideRed)
                                )
                                .cornerRadius(4)
                            }
                        }
                        .frame(height: 220)
                        .padding()
                        .background(Color.strideCardWhite)
                        .cornerRadius(StrideTheme.cornerRadiusCard)
                        .chartYScale(domain: 0...100)
                    }
                }
            }
            .padding()
        }
        .background(Color.strideBackground.ignoresSafeArea())
        .onAppear {
            historyVM.fetchHistoryData(elderlyID: elderlyID)
        }
    }
}
