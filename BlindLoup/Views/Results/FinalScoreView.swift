import SwiftUI

struct FinalScoreView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var podiumVisible = false

    private var ranking: [Player] { vm.finalRanking }

    private var top3: [Player]  { Array(ranking.prefix(3)) }
    private var rest: [Player]  { ranking.count > 3 ? Array(ranking.dropFirst(3)) : [] }

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            VStack(spacing: 0) {
                // Titre
                Text("Résultats")
                    .font(.title.weight(.black))
                    .foregroundStyle(Color.appWhite)
                    .padding(.top, 32)
                    .padding(.bottom, 20)

                // Podium
                PodiumView(top3: top3, visible: podiumVisible)
                    .padding(.horizontal, 16)

                // Bonus invincibilité
                if !vm.invincibilityWinners.isEmpty {
                    VStack(spacing: 8) {
                        HStack {
                            Rectangle()
                                .fill(Color.scoreBonus.opacity(0.4))
                                .frame(height: 1)
                            Text("BONUS PARTIE")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.scoreBonus)
                                .fixedSize()
                            Rectangle()
                                .fill(Color.scoreBonus.opacity(0.4))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 20)

                        ForEach(vm.invincibilityWinners) { player in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.playerColor(player.colorIndex))
                                    .frame(width: 10, height: 10)
                                Text(player.name)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appWhite)
                                Spacer()
                                Text("+20 pts — aucune musique trouvée ✨")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.scoreBonus)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.scoreBonus.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 16)
                }

                // 4e et +
                if !rest.isEmpty {
                    HStack(spacing: 0) {
                        ForEach(Array(rest.enumerated()), id: \.element.id) { idx, player in
                            VStack(spacing: 3) {
                                Text("\(idx + 4)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.appGrey)
                                Text(player.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.playerColor(player.colorIndex))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                Text("\(player.score) pts")
                                    .font(.caption)
                                    .foregroundStyle(Color.appGrey)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .opacity(podiumVisible ? 1 : 0)
                    .offset(y: podiumVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.6), value: podiumVisible)
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

    // ordre : 2e à gauche, 1er au centre, 3e à droite
    private var displayOrder: [(rank: Int, player: Player)] {
        var result: [(Int, Player)] = []
        if top3.count >= 2 { result.append((2, top3[1])) }
        if top3.count >= 1 { result.append((1, top3[0])) }
        if top3.count >= 3 { result.append((3, top3[2])) }
        return result
    }

    private func blockHeight(_ rank: Int) -> CGFloat {
        switch rank {
        case 1: return 120
        case 2: return 95
        default: return 75
        }
    }

    private func medal(_ rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        default: return "🥉"
        }
    }

    // Couleurs podium pastels (or, argent, bronze)
    private func podiumColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color(hex: "#EDD88A")
        case 2: return Color(hex: "#C4C8D4")
        default: return Color(hex: "#D4A870")
        }
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
                let pColor = podiumColor(item.rank)

                VStack(spacing: 0) {
                    // Nom + médaille (au-dessus du bloc)
                    VStack(spacing: 4) {
                        Text(item.player.name)
                            .font(isFirst ? .headline : .subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.playerColor(item.player.colorIndex))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(medal(item.rank))
                            .font(.system(size: isFirst ? 40 : 30))
                    }
                    .padding(.bottom, 8)
                    .scaleEffect(visible ? 1 : 0.5)
                    .opacity(visible ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(delay(item.rank)), value: visible)

                    // Bloc podium avec score à l'intérieur
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(pColor.opacity(0.22))
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(pColor.opacity(isFirst ? 0.9 : 0.6), lineWidth: isFirst ? 2 : 1.5)
                        VStack(spacing: 1) {
                            Text("\(item.player.score)")
                                .font(isFirst ? .title2.weight(.black) : .headline.weight(.black))
                                .foregroundStyle(pColor)
                            Text("pts")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(pColor.opacity(0.8))
                        }
                    }
                    .frame(height: visible ? blockHeight(item.rank) : 0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.7).delay(delay(item.rank) + 0.1), value: visible)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
