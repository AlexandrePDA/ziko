import SwiftUI

struct FinalScoreView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var podiumVisible = false

    private var ranking: [Player] { vm.finalRanking }

    // top 3 et le reste
    private var top3: [Player]  { Array(ranking.prefix(3)) }
    private var rest: [Player]  { ranking.count > 3 ? Array(ranking.dropFirst(3)) : [] }

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            VStack(spacing: 0) {
                // Titre
                Text("RÉSULTATS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appGrey)
                    .textCase(.uppercase)
                    .padding(.top, 32)
                    .padding(.bottom, 20)

                // Podium
                PodiumView(top3: top3, visible: podiumVisible)
                    .padding(.horizontal, 16)

                // 4e et +
                if !rest.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(Array(rest.enumerated()), id: \.element.id) { idx, player in
                            HStack(spacing: 14) {
                                Text("\(idx + 4)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.appGrey)
                                    .frame(width: 28)
                                Text(player.name)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appWhite)
                                Spacer()
                                Text("\(player.score) pts")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.appGrey)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.appNavy)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 20)
                            .opacity(podiumVisible ? 1 : 0)
                            .offset(y: podiumVisible ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.6 + Double(idx) * 0.1), value: podiumVisible)
                        }
                    }
                    .padding(.top, 16)
                }

                Spacer()

                // Actions
                VStack(spacing: 12) {
                    PrimaryButton(title: "Rejouer (mêmes joueurs)") {
                        vm.resetGame(keepPlayers: true)
                    }
                    Button("Retour à l'accueil") {
                        vm.resetGame(keepPlayers: false)
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.appGrey)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.15)) {
                podiumVisible = true
            }
        }
    }
}

// MARK: - Podium

private struct PodiumView: View {
    let top3: [Player]
    let visible: Bool

    // ordre d'affichage : 2e à gauche, 1er au centre, 3e à droite
    private var displayOrder: [(rank: Int, player: Player)] {
        var result: [(Int, Player)] = []
        if top3.count >= 2 { result.append((2, top3[1])) }
        if top3.count >= 1 { result.append((1, top3[0])) }
        if top3.count >= 3 { result.append((3, top3[2])) }
        return result
    }

    // hauteurs des blocs podium
    private func blockHeight(_ rank: Int) -> CGFloat {
        switch rank {
        case 1: return 90
        case 2: return 66
        default: return 50
        }
    }

    private func medal(_ rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        default: return "🥉"
        }
    }

    private func blockColor(_ rank: Int, player: Player) -> Color {
        Color.playerColor(player.colorIndex)
    }

    private func delay(_ rank: Int) -> Double {
        switch rank {
        case 1: return 0.1
        case 2: return 0.25
        default: return 0.4
        }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(displayOrder, id: \.rank) { item in
                let isFirst = item.rank == 1
                VStack(spacing: 0) {
                    // Avatar + nom + score (au-dessus du bloc)
                    VStack(spacing: 4) {
                        Text(medal(item.rank))
                            .font(.system(size: isFirst ? 44 : 34))
                        Text(item.player.name)
                            .font(isFirst ? .headline : .subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appWhite)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text("\(item.player.score) pts")
                            .font(isFirst ? .subheadline : .caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.playerColor(item.player.colorIndex))
                    }
                    .padding(.bottom, 10)
                    .scaleEffect(visible ? 1 : 0.5)
                    .opacity(visible ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(delay(item.rank)), value: visible)

                    // Bloc podium
                    let pColor = blockColor(item.rank, player: item.player)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(pColor.opacity(isFirst ? 0.35 : 0.2))
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(pColor.opacity(isFirst ? 0.9 : 0.5),
                                          lineWidth: isFirst ? 2 : 1)
                        Text("\(item.rank)")
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundStyle(pColor)
                    }
                    .frame(height: visible ? blockHeight(item.rank) : 0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.7).delay(delay(item.rank) + 0.1), value: visible)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
