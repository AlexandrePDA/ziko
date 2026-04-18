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

    @State private var showAirPlayTip = false

    private var round: GameRound? {
        vm.rounds.indices.contains(roundIndex) ? vm.rounds[roundIndex] : nil
    }

    var body: some View {
        ZStack(alignment: .top) {
            BlobBackground()

            if let round {
                VStack(spacing: 0) {
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
                                .accessibilityHidden(true)
                        }
                    }
                    .frame(width: 220, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.5), radius: 24)
                    .accessibilityHidden(true)

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
                        AudioPlayerView(url: round.track.previewURL, color: vm.themeColor)
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
                    PrimaryButton(title: "Voter maintenant", color: vm.themeColor, textColor: .appBackground) {
                        audioService.pause()
                        vm.advancePhase()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 32)
                }
            }

            // AirPlay tip — premier tour uniquement, une seule fois
            if showAirPlayTip {
                AirPlayTipBanner {
                    dismissAirPlayTip()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            guard roundIndex == 0 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    showAirPlayTip = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    dismissAirPlayTip()
                }
            }
        }
    }

    private func dismissAirPlayTip() {
        withAnimation(.easeOut(duration: 0.3)) { showAirPlayTip = false }
    }
}

// MARK: - AirPlay Tip Banner

private struct AirPlayTipBanner: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "airplayvideo")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 32)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 5) {
                Text("Le crime se regarde en grand.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appWhite)

                Text("Connecte ton écran via AirPlay")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appAccent)

                Text("Les verdicts se savourent mieux quand tout le monde les voit tomber en même temps.")
                    .font(.caption)
                    .foregroundStyle(Color.appGreyLight)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 1)
            }

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appGrey)
                    .frame(width: 26, height: 26)
                    .background(Color.appGrey.opacity(0.15))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Fermer le conseil AirPlay")
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .background(Color.appSurface.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.appAccent.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 6)
    }
}
