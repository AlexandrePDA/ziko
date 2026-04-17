import Foundation

struct GameConfig {
    static let freeMaxPlayers       = 4
    static let freeTracksPerPlayer  = 3
    static let premiumTracksOptions = [3, 4, 5, 6]
    static let minPlayers           = 3
    static let previewDuration      = 30.0
}

struct ScoringConfig {
    // Titres du tour
    static let finderPoints         = 10  // 🕯️ LE FIN LIMIER / trouver le propriétaire
    static let soleFinderBonus      = 20  // 🕯️ LE FIN LIMIER — seul à avoir trouvé (cumulatif avec finderPoints → +30 total)
    static let bluffSuccessPoints   = 30  // 🟢 L'INSAISISSABLE — personne ne t'a trouvé
    static let allFoundPenalty      = 10  // ☠️ HONTE SUPRÊME — tout le monde t'a trouvé (pénalité)

    // Titres de fin de partie
    static let invincibilityBonus   = 20  // ⚫ LE CRIME PARFAIT — aucune musique trouvée sur toute la partie
    static let topDetectiveBonus    = 15  // 🔵 L'INSPECTEUR IMPLACABLE — a trouvé le plus de musiques
    static let stalkerBonus         = 15  // 🟣 LE TÉMOIN GÊNANT — a trouvé toutes les musiques d'un joueur

    // Bonus de rôles (mode Rôles secrets)
    static let doublureBonus        = 25  // 🎭 LA DOUBLURE — accusé à l'unanimité à tort au moins 1 fois
    static let obsessionnelBonus    = 30  // 🔎 L'OBSESSIONNEL — voté son suspect 3+ fois et il possède au moins 1 morceau
    static let profilerBonus        = 25  // 📋 LE PROFILER — trouvé des musiques appartenant à 3 joueurs différents
    static let sniperMultiplier     = 2   // 🎯 LE SNIPER — votes corrects × 2 ; votes faux → perd les points
    static let sniperWrongPenalty   = 10  // 🎯 LE SNIPER — pénalité par mauvaise accusation
    static let provocateurMultiplier = 2  // 🃏 LE PROVOCATEUR — doubler la mise : correct × 2, faux × 2 perdu
    static let compliceBonus        = 30  // 🤝 LE COMPLICE — bonus collectif si les 2 complices sont dans le top 3
    static let innocentBonus        = 20  // 😇 L'INNOCENT — accusé à tort plus de 3 fois
}

struct BadgeTitles {
    // Titres du tour
    static let honteSupreme         = "HONTE SUPRÊME"          // ☠️ allFoundPenalty     (-10)
    static let insaisissable        = "L'INSAISISSABLE"         // 🟢 bluffSuccessPoints  (+30)
    static let finLimier            = "LE FIN LIMIER"           // 🕯️ finderPoints + soleFinderBonus (+30)

    // Titres de fin de partie
    static let crimePerfait         = "LE CRIME PARFAIT"        // ⚫ invincibilityBonus  (+20)
    static let inspecteurImplacable = "L'INSPECTEUR IMPLACABLE" // 🔵 topDetectiveBonus   (+15)
    static let temoinGenant         = "LE TÉMOIN GÊNANT"        // 🟣 stalkerBonus        (+15)
}

struct StoreConfig {
    static let premiumProductID = "com.apda.aliiibi.premium"
}

struct StorageKeys {
    static let isPremium           = "isPremium"
    static let gameHistory         = "gameHistory"
    static let hasSeenTutorial     = "hasSeenTutorial"
    static let hasSeenRolesTutorial = "hasSeenRolesTutorial"
}
