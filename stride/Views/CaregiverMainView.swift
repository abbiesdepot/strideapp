//
//  CaregiverMainView.swift
//  stride
//
//  Created by student on 04/06/26.
//

import Foundation
import SwiftUI

struct CaregiverMainView: View {
    var body: some View {
        TabView {
            
            CaregiverHomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            CaregiverPeopleView()
                .tabItem {
                    Label("People", systemImage: "person.2.fill")
                }

            CaregiverProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
    }
}

#Preview {
    CaregiverMainView()
}
