//
//  StressCard.swift
//  stride
//
//  Created by student on 04/06/26.
//

import SwiftUI

struct StressCard: View {
    
    let stress: Int
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Stress")
                .font(.headline)
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("\(stress)%")
                    .font(.system(size: 36, weight: .bold))
                
                Text("Stress")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(height: 130)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 2)
    }
}

