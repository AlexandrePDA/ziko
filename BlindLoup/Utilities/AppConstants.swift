import Foundation

struct GameConfig {
    static let freeMaxPlayers       = 4
    static let freeTracksPerPlayer  = 3
    static let premiumTracksOptions = [3, 4, 5, 6]
    static let minPlayers           = 3
    static let previewDuration      = 30.0
}

struct ScoringConfig {
    static let finderPoints        = 10   // trouver le propriétaire
    static let soleFinderBonus     = 20   // seul à avoir trouvé (cumulatif avec finderPoints)
    static let bluffSuccessPoints  = 30   // propriétaire si personne ne l'a trouvé
    static let allFoundPenalty     = 10   // pénalité propriétaire si tout le monde l'a trouvé
    static let invincibilityBonus  = 20   // aucune musique trouvée sur toute la partie
}

struct StoreConfig {
    static let premiumProductID = "com.blindloup.premium"
}

struct StorageKeys {
    static let isPremium      = "isPremium"
    static let gameHistory    = "gameHistory"
    static let hasSeenTutorial = "hasSeenTutorial"
}
