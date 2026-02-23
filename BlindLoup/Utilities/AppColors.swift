import SwiftUI

extension Color {
    // MARK: - Backgrounds
    static let appBackground = Color(hex: "#111111")   // fond principal
    static let appSurface    = Color(hex: "#1C1C1E")   // cartes / surfaces
    static let appSurface2   = Color(hex: "#2C2C2E")   // surfaces secondaires

    // MARK: - Text
    static let appWhite      = Color(hex: "#FFFFFF")
    static let appGrey       = Color(hex: "#8E8E93")

    // MARK: - Accent (remplace orange)
    static let appAccent     = Color(hex: "#9D9FE5")   // pervenche — CTAs

    // MARK: - Aliases rétro-compatibles (évite de tout casser)
    static var appBlack:  Color { appBackground }
    static var appNavy:   Color { appSurface }
    static var appOrange: Color { appAccent }

    // MARK: - Couleurs joueurs (8 teintes vives sur fond sombre)
    static let playerColors: [Color] = [
        Color(hex: "#7BC47B"),   // 0 — vert sauge
        Color(hex: "#B09FD8"),   // 1 — violet doux
        Color(hex: "#E87ACB"),   // 2 — rose vif
        Color(hex: "#5B8FE8"),   // 3 — bleu royal
        Color(hex: "#C8E020"),   // 4 — citron vert
        Color(hex: "#E8705A"),   // 5 — corail
        Color(hex: "#5BD4C8"),   // 6 — turquoise
        Color(hex: "#F0C060"),   // 7 — doré
    ]

    static func playerColor(_ index: Int) -> Color {
        playerColors[index % playerColors.count]
    }

    // MARK: - Init hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
