//
//  SleepCard.swift
//  stride
//
//  Created by student on 04/06/26.
//

import SwiftUI

struct SleepCard: View {
    
    let awake: String
    let rem: String
    let core: String
    let deep: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Sleep")
                .font(.headline)
            
            SleepRow(color: .red, title: "Awake", value: awake)
            SleepRow(color: .cyan, title: "REM", value: rem)
            SleepRow(color: .blue, title: "Core", value: core)
            SleepRow(color: .purple, title: "Deep", value: deep)
        }
        .padding()
        .frame(height: 130)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 2)
    }
}

struct SleepRow: View {
    
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        
        HStack {
            
            Circle()
                .fill(color)
                .frame(width: 8)
            
            Text(title)
                .font(.caption)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

