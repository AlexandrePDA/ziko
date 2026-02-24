import SwiftUI

// MARK: - Animated blob background

private struct BlobBackground: View {
    @State private var animate = false

    private struct Blob {
        let color: Color
        let size: CGFloat
        let startX: CGFloat
        let startY: CGFloat
        let endX: CGFloat
        let endY: CGFloat
        let duration: Double
    }

    private let blobs: [Blob] = [
        Blob(color: Color.playerColor(3), size: 320, startX: -100, startY: -180, endX:  80, endY:  -60, duration: 7.0),
        Blob(color: Color.playerColor(2), size: 280, startX:  140, startY:  200, endX: -60, endY:  120, duration: 8.5),
        Blob(color: Color.playerColor(0), size: 260, startX:  -60, startY:  120, endX: 100, endY: -100, duration: 6.5),
        Blob(color: Color.playerColor(1), size: 240, startX:  120, startY:  -80, endX: -80, endY:  160, duration: 9.0),
        Blob(color: Color.playerColor(4), size: 200, startX:    0, startY:  260, endX:  40, endY:   40, duration: 7.8),
    ]

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            ForEach(blobs.indices, id: \.self) { i in
                let blob = blobs[i]
                Circle()
                    .fill(blob.color.opacity(0.55))
                    .frame(width: blob.size, height: blob.size)
                    .blur(radius: 90)
                    .offset(
                        x: animate ? blob.endX : blob.startX,
                        y: animate ? blob.endY : blob.startY
                    )
                    .animation(
                        .easeInOut(duration: blob.duration)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.6),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
    }
}

// MARK: - BlindTestView

struct BlindTestView: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(AudioPlayerService.self) private var audioService
    let roundIndex: Int

    var round: GameRound? {
        vm.rounds.indices.contains(roundIndex) ? vm.rounds[roundIndex] : nil
    }

    var body: some View {
        ZStack {
            BlobBackground()

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
                    .shadow(color: .black.opacity(0.5), radius: 24)

                    VStack(spacing: 6) {
                        Text(round.track.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appWhite)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        Text(round.track.artist)
                            .font(.subheadline)
                            .foregroundStyle(Color.appWhite)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 14)

                    Spacer()

                    // Player
                    if round.track.previewURL != nil {
                        AudioPlayerView(url: round.track.previewURL)
                    } else {
                        HStack(spacing: 10) {
                            Image(systemName: "speaker.slash.fill")
                                .foregroundStyle(Color.appGrey)
                            Text("Aperçu audio indisponible")
                                .font(.subheadline)
                                .foregroundStyle(Color.appGrey)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    }

                    // Vote button
                    PrimaryButton(title: "Voter maintenant") {
                        audioService.pause()
                        vm.advancePhase()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}
