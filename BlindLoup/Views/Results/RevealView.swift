import SwiftUI

struct RevealView: View {
    @Environment(GameViewModel.self) private var vm
    let roundIndex: Int

    @State private var countdown = 3
    @State private var revealed = false
    @State private var timer: Timer?
    @State private var showLegende = false

    // MARK: - Derived state

    private var round: GameRound? {
        vm.rounds.indices.contains(roundIndex) ? vm.rounds[roundIndex] : nil
    }

    private var owner: Player? {
        guard let round else { return nil }
        return vm.players.first(where: { $0.id == round.track.ownerID })
    }

    private var correctVoters: [Player] {
        guard let round else { return [] }
        return vm.players.filter { $0.id != round.track.ownerID && round.votes[$0.id] == round.track.ownerID }
    }

    private var otherPlayersCount: Int { vm.players.count - 1 }

    private var scoreCase: ScoreCase {
        let count = correctVoters.count
        if count == 0                  { return .nobodyFound }
        if count == otherPlayersCount  { return .everyoneFound }
        if count == 1                  { return .soleFound }
        return .multipleFound
    }

    private var roundDeltas: [UUID: Int] {
        guard let round else { return [:] }
        return vm.calculateRoundScore(round: round)
    }

    private var playersWithDeltas: [(player: Player, delta: Int)] {
        vm.players
            .compactMap { player -> (Player, Int)? in
                guard let delta = roundDeltas[player.id], delta != 0 else { return nil }
                return (player, delta)
            }
            .sorted { $0.1 > $1.1 }
    }

    private var roundBadges: [RoundBadge] {
        guard let owner else { return [] }
        return RoundBadgeFactory.badges(
            scoreCase: scoreCase,
            owner: owner,
            soleDetective: scoreCase == .soleFound ? correctVoters.first : nil
        )
    }

    private var isLastRound: Bool { roundIndex == vm.rounds.count - 1 }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            if !revealed {
                countdownView
            } else {
                revealedContent
            }
        }
        .onDisappear { timer?.invalidate() }
        .sheet(isPresented: $showLegende) { LegendeView() }
    }

    // MARK: - Countdown

    private var countdownView: some View {
        VStack(spacing: 20) {
            Text("Révélation dans...")
                .font(.title3)
                .foregroundStyle(Color.appGrey)
            Text("\(countdown)")
                .font(.system(size: 100, weight: .black))
                .foregroundStyle(vm.themeColor)
                .contentTransition(.numericText())
                .animation(.spring, value: countdown)
        }
        .onAppear { startCountdown() }
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

    // MARK: - Revealed content

    private var revealedContent: some View {
        VStack(spacing: 0) {
            legendeButton

            ScrollView {
                VStack(spacing: 28) {
                    trackRow
                    ownerSection
                    RoundResultBadges(badges: roundBadges)
                    scoreSection
                }
                .padding(.horizontal, 20)
            }

            PrimaryButton(title: isLastRound ? "Voir les scores finaux" : "Manche suivante", color: vm.themeColor) {
                vm.advancePhase()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
            .background(Color.appBlack)
        }
    }

    private var legendeButton: some View {
        HStack {
            Spacer()
            Button { showLegende = true } label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundStyle(Color.appGrey)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Légende des titres")
        }
        .padding(.horizontal, 12)
    }

    @ViewBuilder
    private var trackRow: some View {
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
            .padding(.top, 4)
        }
    }

    @ViewBuilder
    private var ownerSection: some View {
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
    }

    @ViewBuilder
    private var scoreSection: some View {
        if !playersWithDeltas.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                SectionDividerLabel(title: "SCORE", color: Color.appAccent)

                ForEach(playersWithDeltas, id: \.player.id) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        (Text(item.player.name)
                            .foregroundStyle(Color.playerColor(item.player.colorIndex))
                         + Text(item.delta > 0 ? " remporte " : " perd ")
                            .foregroundStyle(Color.appWhite)
                         + Text("\(abs(item.delta)) pts")
                            .foregroundStyle(Color.appWhite))
                        .font(.title3.weight(.black))

                        if let round {
                            breakdownRows(for: item.player, round: round)
                        }
                    }
                }
            }
            .padding(.bottom, 8)
        }
    }

    // MARK: - Score breakdown (per-player)

    @ViewBuilder
    private func breakdownRows(for player: Player, round: GameRound) -> some View {
        let isOwner      = player.id == round.track.ownerID
        let didFind      = correctVoters.contains { $0.id == player.id }
        let isSole       = scoreCase == .soleFound && didFind
        let usedDoubling = round.doublingVoters.contains(player.id)
        let isSniper     = vm.gameMode == .roles && vm.role(for: player.id) == .sniper
        let isProv       = vm.gameMode == .roles && vm.role(for: player.id) == .provocateur

        VStack(spacing: 8) {
            if isOwner {
                switch scoreCase {
                case .nobodyFound:
                    scoreRow("+30 pts", "Bluffeur parfait 🕵️",        color: Color.appAccent)
                case .everyoneFound:
                    scoreRow("−10 pts", "Tout le monde a trouvé 😬",   color: Color.scorePenalty)
                default:
                    EmptyView()
                }
            } else if didFind {
                scoreRow("+10 pts", "A trouvé le propriétaire 🎯",     color: Color.appAccent)
                if isSole {
                    scoreRow("+20 pts", "Seul(e) à avoir trouvé 🔥",   color: Color.scoreBonus)
                }
                if isSniper {
                    scoreRow("+10 pts", "Bonus Sniper — vote doublé 🎯", color: RoleType.sniper.accentColor)
                }
                if isProv && usedDoubling {
                    scoreRow("+10 pts", "Mise doublée — bonne accusation 🃏", color: RoleType.provocateur.accentColor)
                }
            } else {
                // Mauvais vote — uniquement via modificateurs de rôle
                if isSniper {
                    scoreRow("−\(ScoringConfig.sniperWrongPenalty) pts",
                             "Mauvaise accusation · Sniper 🎯",         color: Color.scorePenalty)
                }
                if isProv && usedDoubling {
                    let penalty = ScoringConfig.finderPoints * ScoringConfig.provocateurMultiplier
                    scoreRow("−\(penalty) pts",
                             "Mise doublée perdue 🃏",                  color: Color.scorePenalty)
                }
            }
        }
    }

    private func scoreRow(_ points: String, _ label: String, color: Color) -> some View {
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
}
