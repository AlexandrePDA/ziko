import Foundation

struct GameRound: Identifiable {
    let id = UUID()
    let track: Track
    var votes: [UUID: UUID] = [:]           // voterID -> votedPlayerID
    var doublingVoters: Set<UUID> = []      // voters who activated Provocateur doubling on this round
    var isRevealed: Bool = false
}
