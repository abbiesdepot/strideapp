import SwiftUI

struct WeeklyHealthTrendView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.strideBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 60))
                        .foregroundColor(.strideSecondary)
                    
                    Text("Daily Report")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.stridePrimary)
                    
                    Text("Charts and trend reports will be available once enough activity data is collected.")
                        .font(.system(size: 16))
                        .foregroundColor(.strideTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .navigationTitle("Trends")
        }
    }
}

#Preview {
    WeeklyHealthTrendView()
}
