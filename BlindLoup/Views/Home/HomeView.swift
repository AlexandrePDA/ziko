import SwiftUI

struct HomeView: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(StoreKitService.self) private var store

    @State private var showPremiumSheet = false
    @State private var showSettings     = false
    @State private var showHowToPlay    = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Top bar ──────────────────────────────────────
                HStack(spacing: 12) {
                    Spacer()

                    // Badge Premium
                    Button(action: { showPremiumSheet = true }) {
                        HStack(spacing: 5) {
                            Image(systemName: "crown.fill")
                            Text(store.isPremium ? "Premium" : "Passer Premium")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(Color.appAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.appAccent.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .accessibilityLabel(store.isPremium ? "Compte Premium" : "Passer à Premium")

                    // Paramètres
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundStyle(Color.appGrey)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Paramètres")
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // ── Logo ─────────────────────────────────────────
                (Text("BLIND").foregroundStyle(Color.appAccent)
                 + Text(" LOUP").foregroundStyle(Color.appWhite))
                    .font(.system(size: 52, weight: .black))
                    .accessibilityLabel("BlindLoup")

                Text("Choisis ton mode de jeu")
                    .font(.subheadline)
                    .foregroundStyle(Color.appGrey)
                    .padding(.top, 6)

                Spacer()

                // ── Mode cards ───────────────────────────────────
                GameModeCard(mode: .classic, isPremium: store.isPremium) {
                    vm.advancePhase()
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        // ── Sheets ───────────────────────────────────────────────
        .sheet(isPresented: $showPremiumSheet) { PremiumPaywallView() }
        .sheet(isPresented: $showSettings)     { SettingsView() }
        .sheet(isPresented: $showHowToPlay)    { HowToPlayView() }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: StorageKeys.hasSeenTutorial) {
                showHowToPlay = true
                UserDefaults.standard.set(true, forKey: StorageKeys.hasSeenTutorial)
            }
        }
    }
}
