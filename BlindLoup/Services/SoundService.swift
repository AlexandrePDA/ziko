import AudioToolbox
import Observation

@Observable
final class SoundService {
    var isMuted: Bool {
        didSet { UserDefaults.standard.set(isMuted, forKey: "soundIsMuted") }
    }

    init() {
        isMuted = UserDefaults.standard.bool(forKey: "soundIsMuted")
    }

    /// Son léger sur les boutons
    func playTap() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1104)
    }

    /// Tick pendant le décompte
    func playCountdownTick() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1052)
    }

    /// Son de révélation
    func playReveal() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(1025)
    }
}
