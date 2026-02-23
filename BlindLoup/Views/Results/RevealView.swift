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
        // Exclude owner voting for themselves
        return vm.players.filter { $0.id != round.track.ownerID && round.votes[$0.id] == round.track.ownerID }
    }

    var otherPlayersCount: Int { vm.players.count - 1 }

    enum ScoreCase {
        case nobodyFound      // +30 for owner
        case everyoneFound    // -10 for owner, +10 each voter
        case soleFound        // +30 for sole finder (+10+20)
        case multipleFound    // +10 each voter
    }

    var scoreCase: ScoreCase {
        let count = correctVoters.count
        if count == 0 { return .nobodyFound }
        if count == otherPlayersCount { return .everyoneFound }
        if count == 1 { return .soleFound }
        return .multipleFound
    }

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            if !revealed {
                // Countdown
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
                // Reveal content
                ScrollView {
                    VStack(spacing: 28) {
                        // Track info
                        if let round {
                            AsyncImage(url: round.track.albumCoverURL) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.appNavy
                            }
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.top, 32)

                            VStack(spacing: 6) {
                                Text(round.track.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.appWhite)
                                    .multilineTextAlignment(.center)
                                Text(round.track.artist)
                                    .font(.headline)
                                    .foregroundStyle(Color.appGrey)
                            }
                        }

                        // Owner reveal
                        if let owner {
                            let ownerColor = Color.playerColor(owner.colorIndex)
                            VStack(spacing: 8) {
                                Text("Ce morceau appartenait à...")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appGrey)
                                Text(owner.name)
                                    .font(.largeTitle)
                                    .fontWeight(.black)
                                    .foregroundStyle(ownerColor)
                            }
                            .padding()
                            .background(ownerColor.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(ownerColor.opacity(0.4), lineWidth: 1.5)
                            )
                        }

                        // Who found it + scoring summary
                        VStack(spacing: 12) {
                            switch scoreCase {
                            case .nobodyFound:
                                VStack(spacing: 6) {
                                    Text("Personne n'a trouvé ! 🕵️")
                                        .font(.headline)
                                        .foregroundStyle(Color.appWhite)
                                        .multilineTextAlignment(.center)
                                    Text("\(owner?.name ?? "") remporte +30 pts")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appAccent)
                                }
                            case .everyoneFound:
                                VStack(spacing: 8) {
                                    Text("Tout le monde a trouvé ! 😬")
                                        .font(.headline)
                                        .foregroundStyle(Color.appWhite)
                                        .multilineTextAlignment(.center)
                                    Text("\(owner?.name ?? "") perd 10 pts")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.red.opacity(0.85))
                                    Text("Ont trouvé (+10 pts chacun) :")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appGrey)
                                    ForEach(correctVoters) { voter in
                                        Text(voter.name)
                                            .font(.headline)
                                            .foregroundStyle(Color.playerColor(voter.colorIndex))
                                    }
                                }
                            case .soleFound:
                                VStack(spacing: 8) {
                                    Text("Seul(e) à avoir trouvé ! 🎯")
                                        .font(.headline)
                                        .foregroundStyle(Color.appWhite)
                                        .multilineTextAlignment(.center)
                                    if let finder = correctVoters.first {
                                        Text("\(finder.name) remporte +30 pts (10+20)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.playerColor(finder.colorIndex))
                                    }
                                }
                            case .multipleFound:
                                VStack(spacing: 8) {
                                    Text("Ont trouvé (+10 pts chacun) :")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appGrey)
                                    ForEach(correctVoters) { voter in
                                        Text(voter.name)
                                            .font(.headline)
                                            .foregroundStyle(Color.playerColor(voter.colorIndex))
                                    }
                                }
                            }
                        }

                        PrimaryButton(title: roundIndex == vm.rounds.count - 1 ? "Voir les scores finaux" : "Manche suivante") {
                            vm.advancePhase()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .onDisappear { timer?.invalidate() }
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
