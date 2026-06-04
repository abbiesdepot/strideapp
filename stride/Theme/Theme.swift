//
//  Theme.swift
//  stride
//
//  Created by abbie on 03/06/26.
//

import SwiftUI

extension Color {
    // brand palette
    static let stridePrimary = Color(hex: "#2E5077")
    static let strideSecondary = Color(hex: "#4DA1A9")
    static let strideTertiary = Color(hex: "#79D7BE")
    static let strideNeutral = Color(hex: "#76777A")
    static let strideBackground = Color(hex: "#F2F4F7")
    static let strideCardWhite = Color.white
    
    // status indicatorsnya
    static let strideGreen = Color(hex: "#4CAF50")
    static let strideYellow = Color(hex: "#FFC107")
    static let strideRed = Color(hex: "#F44336")
    
    // typography
    static let strideTextPrimary = Color(hex: "#2E5077")
    static let strideTextSecondary = Color(hex: "#76777A")
    
    // hex code utility
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// design token constants
struct StrideTheme {
    static let cornerRadiusCard: CGFloat = 16
    static let cornerRadiusButton: CGFloat = 12
    static let shadowRadius: CGFloat = 8
    static let shadowColor = Color.black.opacity(0.06)
}
