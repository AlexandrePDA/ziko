import SwiftUI
import UIKit

struct FinalScoreView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var podiumVisible = false
    @State private var showConfetti = false

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

                // 4e et +
                if !rest.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(Array(rest.enumerated()), id: \.element.id) { idx, player in
                            HStack(spacing: 8) {
                                Text("\(idx + 4)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.appGrey)
                                    .frame(width: 22, alignment: .leading)

                                Spacer()

                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.playerColor(player.colorIndex))
                                        .frame(width: 8, height: 8)
                                    Text(player.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.playerColor(player.colorIndex))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }

                                Spacer()

                                Text("\(player.score) pts")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.appGrey)
                                    .frame(minWidth: 55, alignment: .trailing)
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 16)
                    .opacity(podiumVisible ? 1 : 0)
                    .offset(y: podiumVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.6), value: podiumVisible)
                }

                // Bonus invincibilité (tout en bas du classement)
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
                    .opacity(podiumVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.8), value: podiumVisible)
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

            // Confetti
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.15)) {
                podiumVisible = true
            }
            showConfetti = true
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
                            .font(isFirst ? .title3 : .headline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.playerColor(item.player.colorIndex))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
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

// MARK: - Confetti

private struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> ConfettiContainerView {
        let view = ConfettiContainerView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }
    func updateUIView(_ uiView: ConfettiContainerView, context: Context) {}
}

private class ConfettiContainerView: UIView {
    private var emitterSetUp = false
    private let emitter = CAEmitterLayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !emitterSetUp, bounds.width > 0 else { return }
        emitterSetUp = true
        setupEmitter()
    }

    private func makeCell(color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 7
        cell.lifetime = 5.5
        cell.lifetimeRange = 1.5
        cell.velocity = 320
        cell.velocityRange = 130
        cell.emissionRange = .pi / 4
        cell.emissionLongitude = .pi / 2
        cell.spin = 4
        cell.spinRange = 3
        cell.scale = 0.22
        cell.scaleRange = 0.12
        cell.yAcceleration = 130
        cell.color = color.withAlphaComponent(0.9).cgColor

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 14, height: 9))
        let img = renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 14, height: 9))
        }
        cell.contents = img.cgImage
        return cell
    }

    private func setupEmitter() {
        emitter.emitterPosition = CGPoint(x: bounds.width / 2, y: -10)
        emitter.emitterSize = CGSize(width: bounds.width, height: 1)
        emitter.emitterShape = .line
        emitter.renderMode = .oldestFirst

        let colors: [UIColor] = [
            UIColor(red: 1.00, green: 0.42, blue: 0.42, alpha: 1),
            UIColor(red: 1.00, green: 0.85, blue: 0.24, alpha: 1),
            UIColor(red: 0.42, green: 0.80, blue: 0.47, alpha: 1),
            UIColor(red: 0.31, green: 0.80, blue: 0.77, alpha: 1),
            UIColor(red: 0.66, green: 0.33, blue: 0.97, alpha: 1),
            UIColor(red: 0.96, green: 0.45, blue: 0.71, alpha: 1),
            UIColor(red: 1.00, green: 0.56, blue: 0.10, alpha: 1),
        ]

        emitter.emitterCells = colors.map { makeCell(color: $0) }
        layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.emitter.birthRate = 0
        }
    }
}
