//
//  ElderlyCard.swift
//  stride
//
//  Created by student on 04/06/26.
//

import SwiftUI

struct ElderlyCard: View {

    let elderly: ElderlyProfile

    var body: some View {

        HStack(spacing: 12) {

            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "person.fill")
                }

            VStack(alignment: .leading) {

                HStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 10)
                    
                    Text(elderly.fullName)
                        .font(.headline)
                }

                Text(elderly.liveStatusReason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 3)
    }
}

#Preview {
    ElderlyCard(
        elderly: ElderlyProfile(
            id: nil,
            fullName: "Liana Suwono",
            age: 75,
            photoURL: nil,
            medicalNotes: nil,
            familyID: nil,
            stepCount: 3200,
            distanceKM: 1.2,
            liveStatus: "green",
            liveStatusReason: "Last active 12m ago",
            createdAt: nil
        )
    )
    .padding()
}
