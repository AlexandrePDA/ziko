import SwiftUI

struct RevealView: View {
    @Environment(GameViewModel.self) private var vm
    let roundIndex: Int

    @State private var countdown: Int = 3
    @State private var revealed: Bool = false
    @State private var timer: Timer? = nil

    var round: GameRound? {
        vm.rounds.indices.contains(roundIndex) ? vm.rounds[roundIndex] : nil
    }

    var owner: Player? {
        guard let round else { return nil }
        return vm.players.first(where: { $0.id == round.track.ownerID })
    }

    var correctVoters: [Player] {
        guard let round else { return [] }
        return vm.players.filter { $0.id != round.track.ownerID && round.votes[$0.id] == round.track.ownerID }
    }

    var otherPlayersCount: Int { vm.players.count - 1 }

    enum ScoreCase {
        case nobodyFound
        case everyoneFound
        case soleFound
        case multipleFound
    }

    var scoreCase: ScoreCase {
        let count = correctVoters.count
        if count == 0 { return .nobodyFound }
        if count == otherPlayersCount { return .everyoneFound }
        if count == 1 { return .soleFound }
        return .multipleFound
    }

    // Deltas calculés depuis les votes (avant applyScores)
    private var roundDeltas: [UUID: Int] {
        guard let round else { return [:] }
        return vm.calculateRoundScore(round: round)
    }

    // Joueurs avec des points à afficher, triés (positifs d'abord)
    private var playersWithDeltas: [(player: Player, delta: Int)] {
        vm.players.compactMap { player in
            guard let delta = roundDeltas[player.id], delta != 0 else { return nil }
            return (player, delta)
        }.sorted { $0.delta > $1.delta }
    }

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            if !revealed {
                VStack(spacing: 20) {
                    Text("Révélation dans...")
                        .font(.title3)
                        .foregroundStyle(Color.appGrey)
                    Text("\(countdown)")
                        .font(.system(size: 100, weight: .black))
                        .foregroundStyle(Color.appOrange)
                        .contentTransition(.numericText())
                        .animation(.spring, value: countdown)
                }
                .onAppear { startCountdown() }
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 28) {

                            // ── Track info ────────────────────────────────
                            if let round {
                                HStack(spacing: 14) {
                                    AsyncImage(url: round.track.albumCoverURL) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.appNavy
                                    }
                                    .frame(width: 110, height: 110)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(round.track.title)
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(Color.appWhite)
                                            .lineLimit(2)
                                        Text(round.track.artist)
                                            .font(.subheadline)
                                            .foregroundStyle(Color.appGreyLight)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(.top, 28)
                            }

                            // ── Propriétaire ──────────────────────────────
                            if let owner {
                                VStack(spacing: 6) {
                                    Text("Ce morceau appartenait à")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appGreyLight)
                                    Text(owner.name)
                                        .font(.system(size: 46, weight: .black))
                                        .foregroundStyle(Color.playerColor(owner.colorIndex))
                                        .multilineTextAlignment(.center)
                                }
                            }

                            // ── SCORE section ─────────────────────────────
                            if !playersWithDeltas.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    // Separator
                                    HStack {
                                        Rectangle()
                                            .fill(Color.appAccent.opacity(0.4))
                                            .frame(height: 1)
                                        Text("SCORE")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(Color.appAccent)
                                            .fixedSize()
                                        Rectangle()
                                            .fill(Color.appAccent.opacity(0.4))
                                            .frame(height: 1)
                                    }

                                    // Per-player sections
                                    ForEach(playersWithDeltas, id: \.player.id) { item in
                                        VStack(alignment: .leading, spacing: 8) {
                                            (Text(item.player.name)
                                                .foregroundStyle(Color.playerColor(item.player.colorIndex))
                                             + Text(item.delta > 0 ? " remporte " : " perd ")
                                                .foregroundStyle(Color.appWhite)
                                             + Text("\(abs(item.delta)) pts")
                                                .foregroundStyle(Color.appWhite))
                                            .font(.title3.weight(.black))

                                            if let round = round {
                                                breakdownRows(for: item.player, round: round)
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 8)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // ── Bouton fixé en bas ────────────────────────────────
                    PrimaryButton(title: roundIndex == vm.rounds.count - 1 ? "Voir les scores finaux" : "Manche suivante") {
                        vm.advancePhase()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                    .background(Color.appBlack)
                }
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    @ViewBuilder
    private func breakdownRows(for player: Player, round: GameRound) -> some View {
        let isOwner = player.id == round.track.ownerID
        switch scoreCase {
        case .nobodyFound:
            breakdownRow("+30 pts", "Bluffeur parfait 🕵️", color: Color.appAccent)
        case .everyoneFound:
            if isOwner {
                breakdownRow("−10 pts", "Tout le monde a trouvé 😬", color: Color.scorePenalty)
            } else {
                breakdownRow("+10 pts", "A trouvé le propriétaire 🎯", color: Color.appAccent)
            }
        case .soleFound:
            VStack(spacing: 8) {
                breakdownRow("+10 pts", "A trouvé le propriétaire 🎯", color: Color.appAccent)
                breakdownRow("+20 pts", "Seul(e) à avoir trouvé 🔥", color: Color.scoreBonus)
            }
        case .multipleFound:
            breakdownRow("+10 pts", "A trouvé le propriétaire 🎯", color: Color.appAccent)
        }
    }

    private func breakdownRow(_ points: String, _ label: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Text(points)
                .font(.subheadline.weight(.black))
                .foregroundStyle(color)
                .frame(width: 62, alignment: .leading)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.appWhite)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if countdown > 1 {
                withAnimation { countdown -= 1 }
            } else {
                t.invalidate()
                withAnimation(.spring) { revealed = true }
            }
        }
    }
}
