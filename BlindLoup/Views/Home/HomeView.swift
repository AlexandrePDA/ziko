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
                Text("ALIIIBI")
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(Color.appAccent)
                    .accessibilityLabel("Aliiibi")

                TaglineView()
                    .padding(.top, 10)

                Text("Sélectionne le mode de jeu")
                    .font(.subheadline)
                    .foregroundStyle(Color.appGrey)
                    .padding(.top, 14)

                Spacer()

                // ── Mode cards ───────────────────────────────────
                VStack(spacing: 14) {
                    GameModeCard(mode: .classic, isPremium: store.isPremium) {
                        vm.advancePhase()
                    }

                    GameModeCard(mode: .roles, isPremium: store.isPremium) {
                        if store.isPremium {
                            vm.phase = .rolesMenu
                        } else {
                            showPremiumSheet = true
                        }
                    }
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

// MARK: - Tagline animée mot par mot

private struct TaglineView: View {
    private let words = ["Le", "jeu", "qui", "détruit", "des", "amitiés.","Mais", "en", "rythme." ]
    @State private var visibleCount = 0

    var body: some View {
        HStack(spacing: 5) {
            ForEach(Array(words.enumerated()), id: \.offset) { idx, word in
                Text(word)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(idx == 3 ? Color.appAccent : Color.appGreyLight)
                    .offset(y: visibleCount > idx ? 0 : 8)
                    .opacity(visibleCount > idx ? 1 : 0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.65)
                            .delay(Double(idx) * 0.1),
                        value: visibleCount
                    )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                visibleCount = words.count
            }
        }
    }
}
