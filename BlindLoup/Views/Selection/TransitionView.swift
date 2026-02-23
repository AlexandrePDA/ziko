import SwiftUI

struct TransitionView: View {
    @Environment(GameViewModel.self) private var vm
    let nextPlayerIndex: Int

    var nextPlayer: Player? {
        vm.players.indices.contains(nextPlayerIndex) ? vm.players[nextPlayerIndex] : nil
    }

    var isFirstPlayer: Bool { nextPlayerIndex == 0 }

    var message: String {
        if isFirstPlayer {
            return "Passez le téléphone à \(nextPlayer?.name ?? "").\nRegardez ailleurs !"
        } else {
            return "Au tour de \(nextPlayer?.name ?? "").\nRegardez ailleurs !"
        }
    }

    var body: some View {
        ProtectionScreen(message: message) {
            vm.advancePhase()
        }
    }
}
