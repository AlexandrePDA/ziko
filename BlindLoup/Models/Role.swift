import SwiftUI

// MARK: - RoleType

enum RoleType: String, CaseIterable, Equatable, Codable {
    case doublure
    case obsessionnel
    case profiler
    case sniper
    case provocateur
    case complice
    case innocent
    case melomane

    var emoji: String {
        switch self {
        case .doublure:     return "🎭"
        case .obsessionnel: return "🔎"
        case .profiler:     return "📋"
        case .sniper:       return "🎯"
        case .provocateur:  return "🃏"
        case .complice:     return "🤝"
        case .innocent:     return "😇"
        case .melomane:     return "🎵"
        }
    }

    var title: String {
        switch self {
        case .doublure:     return "La Doublure"
        case .obsessionnel: return "L'Obsessionnel"
        case .profiler:     return "Le Profiler"
        case .sniper:       return "Le Sniper"
        case .provocateur:  return "Le Provocateur"
        case .complice:     return "Le Complice"
        case .innocent:     return "L'Innocent"
        case .melomane:     return "Le Mélomane"
        }
    }

    var tagline: String {
        switch self {
        case .doublure:
            return "Tu es trop prévisible ? Parfait. C'est exactement ce que tu veux leur faire croire."
        case .obsessionnel:
            return "Tu as un suspect. Un seul. Et tu as décidé que c'était lui. Point."
        case .profiler:
            return "Tu analyses. Tu déduis. Tu profiles."
        case .sniper:
            return "Tu n'accuses pas souvent. Mais quand tu le fais, t'as pas intérêt à te planter."
        case .provocateur:
            return "Tu n'as pas de stratégie. Tu as quelque chose de mieux : l'instinct du chaos."
        case .complice:
            return "Toi et un autre joueur, vous vous êtes regardés. Vous avez compris."
        case .innocent:
            return "Tu n'as rien fait. Tu n'as rien vu. Et pourtant, tout le monde va te regarder bizarrement."
        case .melomane:
            return "Pas de mission. Pas de complot. Juste toi, ta playlist, et une confiance naïve en tes amis."
        }
    }

    var mission: String {
        switch self {
        case .doublure:
            return "Fais-toi accuser à l'unanimité — à tort — au moins une fois. Laisse-les faire. Joue la comédie."
        case .obsessionnel:
            return "Choisis un suspect maintenant et accuse-le sur au moins 3 morceaux. S'il en possède un seul, tu décroches le bonus."
        case .profiler:
            return "Trouve des musiques appartenant à 3 joueurs différents au cours de la partie. Chaque indice compte."
        case .sniper:
            return "Bonne accusation → points doublés. Mauvaise → tu en perds. Réfléchis avant de parler. Ou pas. Mais assume."
        case .provocateur:
            return "Tu peux choisir de \"doubler la mise\" sur une accusation. Bonne → points × 2. Mauvaise → points perdus × 2."
        case .complice:
            return "Si vous finissez tous les deux dans le top 3, vous partagez un bonus collectif. L'alliance secrète."
        case .innocent:
            return "Si tu te fais accuser à tort plus de 3 fois sans jamais être le vrai coupable, tu décroches le bonus victime expiatoire."
        case .melomane:
            return "Aucune mission. Aucun bonus. Aucune prise de tête. Profite juste de la musique."
        }
    }

    var bonusLabel: String {
        switch self {
        case .doublure:     return "+\(ScoringConfig.doublureBonus) pts si accusé à l'unanimité à tort"
        case .obsessionnel: return "+\(ScoringConfig.obsessionnelBonus) pts si mission accomplie"
        case .profiler:     return "+\(ScoringConfig.profilerBonus) pts si 3 joueurs profilés"
        case .sniper:       return "× \(ScoringConfig.sniperMultiplier) si correct, -\(ScoringConfig.sniperWrongPenalty) pts si faux"
        case .provocateur:  return "× \(ScoringConfig.provocateurMultiplier) sur la mise doublée"
        case .complice:     return "+\(ScoringConfig.compliceBonus) pts collectifs si top 3"
        case .innocent:     return "+\(ScoringConfig.innocentBonus) pts si accusé à tort 3+ fois"
        case .melomane:     return "Aucun bonus — joue pour le plaisir"
        }
    }

    var accentColor: Color {
        switch self {
        case .doublure:     return Color(hex: "#E57373")
        case .obsessionnel: return Color(hex: "#FFB74D")
        case .profiler:     return Color(hex: "#4FC3F7")
        case .sniper:       return Color(hex: "#81C784")
        case .provocateur:  return Color(hex: "#CE93D8")
        case .complice:     return Color(hex: "#F06292")
        case .innocent:     return Color(hex: "#B0BEC5")
        case .melomane:     return Color(hex: "#80CBC4")  // turquoise doux
        }
    }

    /// Whether this role has an end-game bonus to display
    var hasBonus: Bool {
        self != .melomane && self != .sniper && self != .provocateur
    }

    /// Roles available as base pool (complice & profiler added separately based on count)
    static func availableRoles(for playerCount: Int) -> [RoleType] {
        var roles: [RoleType] = [.doublure, .obsessionnel, .sniper, .provocateur, .innocent, .melomane]
        if playerCount >= 5 {
            roles.append(.profiler)
        }
        // 7+ players: a second mélomane can appear
        if playerCount > 6 {
            roles.append(.melomane)
        }
        return roles
    }
}

// MARK: - Role assignment

extension RoleType {
    /// Assign roles randomly to the given player IDs.
    /// Complice is given to exactly 2 players when count >= 5.
    /// Returns a [playerID: RoleType] dictionary.
    static func assign(to playerIDs: [UUID]) -> [UUID: RoleType] {
        let n = playerIDs.count
        var shuffled = playerIDs.shuffled()
        var result: [UUID: RoleType] = [:]

        if n >= 5 {
            result[shuffled[0]] = .complice
            result[shuffled[1]] = .complice
            shuffled = Array(shuffled.dropFirst(2))
        }

        let pool = availableRoles(for: n).shuffled()
        for (i, playerID) in shuffled.enumerated() {
            result[playerID] = pool[i % pool.count]
        }

        return result
    }
}
