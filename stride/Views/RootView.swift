//
//  RootView.swift
//  stride
//
//  Created by abbie on 03/06/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authContext: AuthViewModel
    
    var body: some View {
        Group {
            if authContext.isSessionChecking {
                ZStack {
                    Color.strideBackground.ignoresSafeArea()
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: StrideTheme.cornerRadiusCard)
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 140, height: 140)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 180, height: 22)
                    }
                }
            } else if let user = authContext.currentUser {
                if user.role == "caregiver" {
                    CaregiverMainView()
                } else if user.role == "family_member" {
                    FamilyMainView()
                } else {
                    OnboardingRoleSelectView()
                }
            } else {
                OnboardingRoleSelectView()
            }
        }
    }
}

struct CaregiverMainView: View {
    @EnvironmentObject var authContext: AuthViewModel
    var body: some View {
        VStack {
            Text("Caregiver Workspace Active")
                .font(.system(size: 17, weight: .bold))
            Button("Log Out") { authContext.signOutSession() }
        }
    }
}

struct FamilyMainView: View {
    @EnvironmentObject var authContext: AuthViewModel
    var body: some View {
        VStack {
            Text("Family Workspace Active")
                .font(.system(size: 17, weight: .bold))
            Button("Log Out") { authContext.signOutSession() }
        }
    }
}

#Preview {
    RootView()
}
