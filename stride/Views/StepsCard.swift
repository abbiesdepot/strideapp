//
//  StepsCard.swift
//  stride
//
//  Created by student on 04/06/26.
//

import SwiftUI

struct StepsCard: View {
    
    let stepCount: Int
    let distanceKM: Double
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Steps")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack {
                
                Image(systemName: "figure.walk")
                    .font(.title)
                
                VStack(alignment: .leading) {
                    
                    Text("\(stepCount)")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("\(distanceKM, specifier: "%.1f") KM")
                        .font(.caption)
                }
            }
            .foregroundColor(.white)
        }
        .padding()
        .frame(height: 130)
        .background(Color(hex: "#35557F"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

