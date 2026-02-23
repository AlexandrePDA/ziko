import SwiftUI

struct BlindTestView: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(AudioPlayerService.self) private var audioService
    let roundIndex: Int

    var round: GameRound? {
        vm.rounds.indices.contains(roundIndex) ? vm.rounds[roundIndex] : nil
    }

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            if let round {
                VStack(spacing: 0) {
                    // Round indicator
                    HStack {
                        Text("Manche \(roundIndex + 1)/\(vm.rounds.count)")
                            .font(.caption)
                            .foregroundStyle(Color.appGrey)
                            .textCase(.uppercase)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    Spacer()

                    // Album art
                    AsyncImage(url: round.track.albumCoverURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ZStack {
                            Color.appNavy
                            Image(systemName: "music.note")
                                .font(.system(size: 64))
                                .foregroundStyle(Color.appOrange)
                        }
                    }
                    .frame(width: 220, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Spacer()

                    // Player
                    AudioPlayerView(url: round.track.previewURL)
                        .padding(.bottom, 8)

                    // Vote button
                    PrimaryButton(title: "Voter maintenant") {
                        audioService.pause()
                        vm.advancePhase()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}
