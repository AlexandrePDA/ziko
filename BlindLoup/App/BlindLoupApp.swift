import SwiftUI

@main
struct BlindLoupApp: App {
    @State private var storeService: StoreKitService
    @State private var audioService: AudioPlayerService
    @State private var soundService: SoundService
    @State private var gameVM: GameViewModel

    init() {
        let store = StoreKitService()
        _storeService = State(initialValue: store)
        _audioService = State(initialValue: AudioPlayerService())
        _soundService = State(initialValue: SoundService())
        _gameVM = State(initialValue: GameViewModel(storeService: store))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(gameVM)
                .environment(audioService)
                .environment(soundService)
                .environment(storeService)
                .preferredColorScheme(.dark)
        }
    }
}
