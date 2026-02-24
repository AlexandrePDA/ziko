import SwiftUI

struct TransitionView: View {
    @Environment(GameViewModel.self) private var vm
    let nextPlayerIndex: Int

    var nextPlayer: Player? {
        vm.players.indices.contains(nextPlayerIndex) ? vm.players[nextPlayerIndex] : nil
    }

    var isFirstPlayer: Bool { nextPlayerIndex == 0 }

    var messageLabel: Text {
        let name = nextPlayer?.name ?? ""
        let color = Color.playerColor(nextPlayer?.colorIndex ?? 0)
        let nameText = Text(name).foregroundStyle(color)
        let suffix = Text(".\nRegardez ailleurs !").foregroundStyle(Color.appWhite)
        if isFirstPlayer {
            return Text("Passez le téléphone à ").foregroundStyle(Color.appWhite)
                + nameText + suffix
        } else {
            return Text("Au tour de ").foregroundStyle(Color.appWhite)
                + nameText + suffix
        }
    }

    var body: some View {
        ProtectionScreen(message: messageLabel) {
            vm.advancePhase()
        }
    }
}
