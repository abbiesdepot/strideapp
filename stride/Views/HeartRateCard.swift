//
//  HeartRateCard.swift
//  stride
//
//  Created by student on 04/06/26.
//

import SwiftUI

struct HeartRateCard: View {
    
    let heartRate: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Heart Rate")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Current")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(Int(heartRate))")
                        .font(.system(size: 42, weight: .bold))
                    
                    Text("BPM")
                        .font(.headline)
                }
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(height: 130)
        .background(Color(hex: "#35557F"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    HeartRateCard(heartRate: 68)
        .padding()
}
