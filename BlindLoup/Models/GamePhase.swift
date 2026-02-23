import Foundation

enum GamePhase: Equatable {
    case home
    case setup
    case secretSelection(playerIndex: Int)
    case transition(nextPlayerIndex: Int)
    case blindTest(roundIndex: Int)
    case voting(roundIndex: Int)
    case reveal(roundIndex: Int)
    case finalResults
}
