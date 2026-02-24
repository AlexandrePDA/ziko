import SwiftUI

extension Color {
    // MARK: - Backgrounds
    static let appBackground = Color(hex: "#111111")   // fond principal
    static let appSurface    = Color(hex: "#1C1C1E")   // cartes / surfaces
    static let appSurface2   = Color(hex: "#2C2C2E")   // surfaces secondaires

    // MARK: - Text
    static let appWhite      = Color(hex: "#FFFFFF")
    static let appGrey       = Color(hex: "#8E8E93")
    static let appGreyLight  = Color(hex: "#C4C4C9")   // gris clair proche du blanc

    // MARK: - Accent
    static let appAccent     = Color(hex: "#9D9FE5")   // pervenche — CTAs

    // MARK: - Couleurs scoring (fixes, indépendantes des joueurs)
    static let scorePositive = Color(hex: "#9D9FE5")   // pervenche — points positifs
    static let scorePenalty  = Color(hex: "#E86060")   // rouge — pénalité
    static let scoreBonus    = Color(hex: "#7BC47B")   // vert sauge — bonus

    // MARK: - Aliases rétro-compatibles
    static var appBlack:  Color { appBackground }
    static var appNavy:   Color { appSurface }
    static var appOrange: Color { appAccent }

    // MARK: - Couleurs joueurs (8 teintes pastels, distinctes des couleurs scoring)
    static let playerColors: [Color] = [
        Color(hex: "#FFAB76"),   // 0 — saumon
        Color(hex: "#FFE270"),   // 1 — jaune doux
        Color(hex: "#D98AE0"),   // 2 — lilas
        Color(hex: "#72DDD4"),   // 3 — menthe
        Color(hex: "#FF9CC0"),   // 4 — rose poudré
        Color(hex: "#A89EFF"),   // 5 — lavande
        Color(hex: "#79CCFF"),   // 6 — bleu ciel
        Color(hex: "#FFCC7A"),   // 7 — miel
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
