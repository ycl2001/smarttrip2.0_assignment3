import SwiftUI
import UIKit

enum SmartTripColors {
    static let primary = Color(hex: 0x084D46)
    static let accent = Color(hex: 0x029B8D)
    static let warmAccent = Color(hex: 0xA4612D)
    static let deepBrown = Color(hex: 0x321D0E)
    static let highlight = Color(hex: 0xFFC036)

    static let background = Color(
        light: Color(hex: 0xF4F4F4),
        dark: Color(hex: 0x101414)
    )

    static let surface = Color(
        light: .white,
        dark: Color(hex: 0x1A1C1C)
    )

    static let surfaceMuted = Color(
        light: Color(hex: 0xEEEEEE),
        dark: Color(hex: 0x2F3131)
    )

    static let textPrimary = Color(
        light: Color(hex: 0x2B2B2B),
        dark: Color(hex: 0xF1F1F1)
    )

    static let textSecondary = Color(
        light: Color(hex: 0x666666),
        dark: Color(hex: 0xBFC9C6)
    )

    static let divider = Color(
        light: Color(hex: 0xD0D0D0),
        dark: Color(hex: 0x404947)
    )

    static let success = Color(hex: 0x38B000)
    static let warning = Color(hex: 0xFFBE0B)
    static let error = Color(hex: 0xBA1A1A)
}

private extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                UIColor(dark)
            default:
                UIColor(light)
            }
        })
    }
}
