import SwiftUI

struct HomeView: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(StoreKitService.self) private var store

    @State private var showPremiumSheet    = false
    @State private var showSettings        = false
    @State private var showRolesComingSoon = false
    @State private var showHowToPlay       = false

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

                    // Roue crantée — Paramètres
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundStyle(Color.appGrey)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // ── Logo ─────────────────────────────────────────
                (Text("BLIND").foregroundStyle(Color.appAccent)
                 + Text(" LOUP").foregroundStyle(Color.appWhite))
                    .font(.system(size: 52, weight: .black))

                Text("Choisis ton mode de jeu")
                    .font(.subheadline)
                    .foregroundStyle(Color.appGrey)
                    .padding(.top, 6)

                Spacer()

                // ── Mode cards ───────────────────────────────────
                VStack(spacing: 14) {
                    GameModeCard(mode: .classic, isPremium: store.isPremium) {
                        vm.advancePhase()
                    }

                    GameModeCard(mode: .roles, isPremium: store.isPremium) {
                        if store.isPremium {
                            showRolesComingSoon = true
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
        // ── Alerts ───────────────────────────────────────────────
        .alert("Bientôt disponible", isPresented: $showRolesComingSoon) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Le mode Loup-Garou avec rôles secrets arrive très prochainement. Reste connecté !")
        }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: StorageKeys.hasSeenTutorial) {
                showHowToPlay = true
                UserDefaults.standard.set(true, forKey: StorageKeys.hasSeenTutorial)
            }
        }
    }
}
