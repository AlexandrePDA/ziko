import Foundation

struct GameRound: Identifiable {
    let id: UUID = UUID()
    let track: Track
    var votes: [UUID: UUID] = [:]   // voterID -> votedPlayerID
    var isRevealed: Bool = false
}
