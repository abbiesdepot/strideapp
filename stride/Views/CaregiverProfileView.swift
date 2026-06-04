//
//  CaregiverProfileView.swift
//  stride
//
//  Created by student on 04/06/26.
//

import SwiftUI

struct CaregiverProfileView: View {
    @EnvironmentObject var authContext: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(authContext.currentUser?.fullName ?? "Unknown User")

                Button("Log Out") {
                    authContext.signOutSession()
                }
                .foregroundColor(.red)
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    CaregiverProfileView()
}
