import SwiftUI

struct WeeklyHealthTrendView: View {
    let elderlyID: String
    
    var body: some View {
        WeeklyHealthChartsView(elderlyID: elderlyID)
            .navigationTitle("Weekly Trends")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    WeeklyHealthTrendView(elderlyID: "preview_elderly_id")
}
