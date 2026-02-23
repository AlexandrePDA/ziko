import SwiftUI

struct AudioPlayerView: View {
    @Environment(AudioPlayerService.self) private var audioService
    let url: URL?

    var body: some View {
        VStack(spacing: 16) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appNavy)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appOrange)
                        .frame(width: geo.size.width * audioService.progress, height: 6)
                        .animation(.linear(duration: 0.1), value: audioService.progress)
                }
            }
            .frame(height: 6)

            // Time labels
            HStack {
                Text(formatTime(audioService.progress * audioService.duration))
                    .font(.caption)
                    .foregroundStyle(Color.appGrey)
                Spacer()
                Text(formatTime(audioService.duration))
                    .font(.caption)
                    .foregroundStyle(Color.appGrey)
            }

            // Controls
            HStack(spacing: 40) {
                Button(action: {
                    let delta = audioService.duration > 0 ? 10.0 / audioService.duration : 0
                    audioService.seek(to: max(0, audioService.progress - delta))
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.title2)
                        .foregroundStyle(Color.appWhite)
                }

                Button(action: togglePlayPause) {
                    Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.appOrange)
                }

                Button(action: {
                    let delta = audioService.duration > 0 ? 10.0 / audioService.duration : 0
                    audioService.seek(to: min(1, audioService.progress + delta))
                }) {
                    Image(systemName: "goforward.10")
                        .font(.title2)
                        .foregroundStyle(Color.appWhite)
                }
            }
        }
        .padding(.horizontal, 24)
        .onAppear { startPlayback() }
        .onDisappear { audioService.stop() }
    }

    private func togglePlayPause() {
        if audioService.isPlaying { audioService.pause() } else { audioService.resume() }
    }

    private func startPlayback() {
        guard let url else { return }
        audioService.play(url: url)
    }

    private func formatTime(_ seconds: Double) -> String {
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}
