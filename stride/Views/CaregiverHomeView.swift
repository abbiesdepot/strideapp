//
//  CaregiverHomeView.swift
//  stride
//
//  Created by student on 04/06/26.
//

import Foundation
import SwiftUI

struct CaregiverHomeView: View {
    
    // Warna custom menyesuaikan desain UI
    let darkBlue = Color(red: 0.22, green: 0.31, blue: 0.44) // #384F70
    let bgCream = Color(red: 0.97, green: 0.96, blue: 0.94)  // #F8F6F0
    
    // Asumsi model struct Anda sesuai dengan yang diinstansiasi
    let elderly = ElderlyProfile(
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // 1. Header Section
                headerSection
                
                // 2. Dashboard Profile & Cards
                dashboardContainer
                
                // 3. To Do Section
                todoSection
                
                // 4. Recent Section
                recentSection
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Text("Hi Michelle!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(darkBlue)
            
            Spacer()
            
            Image(systemName: "bell.fill")
                .font(.title2)
                .foregroundColor(darkBlue)
        }
    }
    
    // MARK: - Dashboard Container
    private var dashboardContainer: some View {
        VStack(spacing: 20) {
            // Profile Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.82, green: 0.90, blue: 0.90))
                        .frame(width: 60, height: 60)
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color(red: 0.35, green: 0.60, blue: 0.60))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                        
                        Text(elderly.fullName ?? "Liana Suwono")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(darkBlue)
                    }
                    
                    Text(elderly.liveStatusReason ?? "Last active 12m ago")
                        .font(.caption)
                        .foregroundColor(darkBlue.opacity(0.8))
                }
                Spacer()
            }
            
            // Cards Grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                heartRateCard
                sleepCard
                stressCard
                stepsCard
            }
        }
        .padding(20)
        .background(bgCream)
        .cornerRadius(24)
    }
    
    // MARK: - Individual Cards
    private var heartRateCard: some View {
        VStack(alignment: .leading) {
            Text("Heart Rate")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            VStack(spacing: 4) {
                Text("Current")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("68") // Hardcoded mockup value
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                    Text("BPM")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(16)
        .frame(height: 160)
        .background(darkBlue)
        .cornerRadius(16)
    }
    
    private var sleepCard: some View {
        VStack(alignment: .leading) {
            Text("Sleep")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(darkBlue)
            Spacer()
            VStack(spacing: 6) {
                sleepRow(color: Color(red: 0.94, green: 0.49, blue: 0.40), label: "Awake", time: "6 min")
                sleepRow(color: Color(red: 0.54, green: 0.84, blue: 0.95), label: "REM", time: "1 hr 45 min")
                sleepRow(color: Color(red: 0.38, green: 0.55, blue: 0.96), label: "Core", time: "4 hr 48 min")
                sleepRow(color: Color(red: 0.42, green: 0.34, blue: 0.89), label: "Deep", time: "37 min")
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(16)
        .frame(height: 160)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    private func sleepRow(color: Color, label: String, time: String) -> some View {
        HStack {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 12, weight: .medium)).foregroundColor(darkBlue)
            Spacer()
            Text(time).font(.system(size: 12, weight: .bold)).foregroundColor(darkBlue)
        }
    }
    
    private var stressCard: some View {
        VStack(alignment: .leading) {
            Text("Stress")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(darkBlue)
            Spacer()
            VStack(spacing: 0) {
                Text("67%") // Hardcoded mockup value
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(darkBlue)
                Text("Stress")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(darkBlue)
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(16)
        .frame(height: 160)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    private var stepsCard: some View {
        VStack(alignment: .leading) {
            Text("Steps")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            VStack(spacing: 6) {
                HStack(alignment: .center, spacing: 6) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(elderly.stepCount ?? 3200)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                HStack(spacing: 4) {
                    Text(String(format: "%.1f KM", elderly.distanceKM ?? 1.2))
                        .font(.system(size: 12, weight: .bold))
                    Text("Distance")
                        .font(.system(size: 12))
                }
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(16)
        .frame(height: 160)
        .background(darkBlue)
        .cornerRadius(16)
    }
    
    // MARK: - To Do Section
    private var todoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("To Do")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(darkBlue)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Shower")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(darkBlue)
                    Text("10.30 - 11.30")
                        .font(.system(size: 14))
                        .foregroundColor(darkBlue.opacity(0.8))
                }
                Spacer()
                Circle()
                    .stroke(darkBlue, lineWidth: 1.5)
                    .frame(width: 24, height: 24)
            }
            .padding(16)
            .background(bgCream)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Recent Section
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(darkBlue)
            
            recentItem(title: "Breakfast", time: "08.00 - 09.00")
            recentItem(title: "Medicine", time: "09.00 - 09.30")
        }
    }
    
    private func recentItem(title: String, time: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .strikethrough(true, color: darkBlue)
                    .foregroundColor(darkBlue)
                Text(time)
                    .font(.system(size: 14))
                    .foregroundColor(darkBlue.opacity(0.8))
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(darkBlue)
                    .frame(width: 24, height: 24)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(bgCream)
        .cornerRadius(16)
    }
}

#Preview {
    CaregiverHomeView()
}

