import Foundation
import AVFoundation
import Observation

@Observable
final class AudioPlayerService {
    var progress: Double = 0.0
    var isPlaying: Bool = false
    var duration: Double = GameConfig.previewDuration

    private var player: AVPlayer?
    private var timeObserver: Any?

    init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.defaultToSpeaker]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            #if DEBUG
            print("AudioSession error: \(error)")
            #endif
        }
    }

    func play(url: URL) {
        stop()
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        addPeriodicObserver()
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func stop() {
        removePeriodicObserver()
        player?.pause()
        player = nil
        progress = 0.0
        isPlaying = false
    }

    func seek(to fraction: Double) {
        guard let player else { return }
        let targetTime = CMTime(seconds: fraction * duration, preferredTimescale: 600)
        player.seek(to: targetTime)
    }

    private func addPeriodicObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let current = time.seconds
            let dur = self.player?.currentItem?.duration.seconds ?? GameConfig.previewDuration
            if dur > 0 && !dur.isNaN {
                self.duration = dur
                self.progress = current / dur
            }
            if self.progress >= 1.0 {
                self.stop()
            }
        }
    }

    private func removePeriodicObserver() {
        if let observer = timeObserver, let player {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
}
