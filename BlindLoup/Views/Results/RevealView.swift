import SwiftUI

struct RevealView: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(SoundService.self) private var sound
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
        sound.playCountdownTick()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if countdown > 1 {
                withAnimation { countdown -= 1 }
                sound.playCountdownTick()
            } else {
                t.invalidate()
                sound.playReveal()
                withAnimation(.spring) { revealed = true }
            }
        }
    }

    // MARK: - Revealed content

    private var revealedContent: some View {
        VStack(spacing: 0) {
            legendeButton

            ScrollView {
                VStack(spacing: 20) {
                    trackRow
                    ownerSection
                    if let round {
                        RoundResultSection(
                            round: round,
                            players: vm.players,
                            scoreCase: scoreCase,
                            playerRoles: vm.playerRoles
                        )
                    }
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
}
