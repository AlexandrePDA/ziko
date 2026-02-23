import SwiftUI

struct RootView: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            switch vm.phase {
            case .home:
                HomeView()
                    .transition(.opacity)

            case .setup:
                PlayerSetupView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .secretSelection(let idx):
                SecretSelectionView(playerIndex: idx)
                    .id("selection-\(idx)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .transition(let nextIdx):
                TransitionView(nextPlayerIndex: nextIdx)
                    .id("transition-\(nextIdx)")
                    .transition(.opacity)

            case .blindTest(let idx):
                BlindTestView(roundIndex: idx)
                    .id("blindtest-\(idx)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .voting(let idx):
                VotingView(roundIndex: idx)
                    .id("voting-\(idx)")
                    .transition(.opacity)

            case .reveal(let idx):
                RevealView(roundIndex: idx)
                    .id("reveal-\(idx)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .opacity
                    ))

            case .finalResults:
                FinalScoreView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.phase)
    }
}
