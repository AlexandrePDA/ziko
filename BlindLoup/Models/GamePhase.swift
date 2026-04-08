import Foundation

enum GamePhase: Equatable {
    case home
    case classicMenu
    case rolesMenu
    case setup
    case roleReveal(playerIndex: Int)   // Roles mode only: shows role card before music selection
    case secretSelection(playerIndex: Int)
    case transition(nextPlayerIndex: Int)
    case blindTest(roundIndex: Int)
    case voting(roundIndex: Int)
    case reveal(roundIndex: Int)
    case finalResults
}
