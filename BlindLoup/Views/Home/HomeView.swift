import SwiftUI

struct HomeView: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(StoreKitService.self) private var store

    @State private var showPremiumSheet    = false
    @State private var showHowToPlay       = false
    @State private var showHistory         = false
    @State private var showRolesComingSoon = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Top bar ──────────────────────────────────────
                HStack {
                    Button(action: { showHowToPlay = true }) {
                        HStack(spacing: 5) {
                            Image(systemName: "questionmark.circle")
                            Text("Comment jouer ?")
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color.appGrey)
                    }

                    Spacer()

                    Button(action: {
                        store.isPremium ? (showHistory = true) : (showPremiumSheet = true)
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Historique")
                                .font(.subheadline)
                        }
                        .foregroundStyle(store.isPremium ? Color.appGrey : Color.appAccent.opacity(0.8))
                        .overlay(alignment: .topTrailing) {
                            if !store.isPremium {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 8))
                                    .foregroundStyle(Color.appAccent)
                                    .offset(x: 4, y: -4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // ── Logo ─────────────────────────────────────────
                VStack(spacing: 2) {
                    Text("BLIND")
                        .font(.system(size: 52, weight: .black))
                        .foregroundStyle(Color.appAccent)
                    Text("LOUP")
                        .font(.system(size: 52, weight: .black))
                        .foregroundStyle(Color.appWhite)
                }

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

                // ── Badge premium ────────────────────────────────
                if !store.isPremium {
                    Button(action: { showPremiumSheet = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                            Text("Passer Premium")
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.appAccent)
                    }
                    .padding(.bottom, 40)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                        Text("Premium actif")
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.appAccent)
                    .padding(.bottom, 40)
                }
            }
        }
        // ── Sheets ───────────────────────────────────────────────
        .sheet(isPresented: $showHowToPlay)    { HowToPlayView() }
        .sheet(isPresented: $showPremiumSheet) { PremiumPaywallView() }
        .sheet(isPresented: $showHistory)      { GameHistoryView() }
        // ── Alerts ───────────────────────────────────────────────
        .alert("Bientôt disponible", isPresented: $showRolesComingSoon) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Le mode Loup-Garou avec rôles secrets arrive très prochainement. Reste connecté !")
        }
        .onAppear {
            let seen = UserDefaults.standard.bool(forKey: StorageKeys.hasSeenTutorial)
            if !seen {
                showHowToPlay = true
                UserDefaults.standard.set(true, forKey: StorageKeys.hasSeenTutorial)
            }
        }
    }
}
