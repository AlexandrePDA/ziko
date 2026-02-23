import Foundation

struct GameSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let players: [PlayerResult]

    struct PlayerResult: Codable {
        let name: String
        let score: Int
    }
}

final class GameHistoryService {
    static let shared = GameHistoryService()

    private let key = StorageKeys.gameHistory
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func saveSession(players: [Player]) {
        var history = loadHistory()
        let session = GameSession(
            id: UUID(),
            date: Date(),
            players: players.map { GameSession.PlayerResult(name: $0.name, score: $0.score) }
        )
        history.append(session)
        if let data = try? encoder.encode(history) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadHistory() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let history = try? decoder.decode([GameSession].self, from: data) else {
            return []
        }
        return history
    }

    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
