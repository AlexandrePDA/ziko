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

                    // Badge Premium (masqué si déjà abonné)
                    if !store.isPremium {
                        Button(action: { showPremiumSheet = true }) {
                            HStack(spacing: 5) {
                                Text("👑")
                                Text("Passer ALIIIBI+")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(Color.appPremiumGold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.appPremiumGold.opacity(0.22))
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(Color.appPremiumGold.opacity(0.7), lineWidth: 1))
                        }
                        .accessibilityLabel("Passer à ALIIIBI+")
                    }

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
                NeonTitleView()
                    .accessibilityLabel("Aliiibi")

                TaglineView()
                    .padding(.top, 10)

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
        .sheet(isPresented: $showHowToPlay)    { HowToPlayView(isOnboarding: true) }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: StorageKeys.hasSeenTutorial) {
                showHowToPlay = true
                UserDefaults.standard.set(true, forKey: StorageKeys.hasSeenTutorial)
            }
        }
    }
}

// MARK: - Titre avec effet néon

struct NeonTitleView: View {
    var size: CGFloat = 52
    private let colors: [Color] = [
        Color.appAccent,
        Color(hex: "#7BC47B"),
        Color(hex: "#FF9CC0"),
        Color(hex: "#72DDD4"),
        Color(hex: "#A89EFF"),
        Color(hex: "#FFAB76"),
    ]
    @State private var colorIndex = 0
    @State private var neonTimer: Timer? = nil

    var body: some View {
        Text("Aliiibi")
            .font(.system(size: size, weight: .black))
            .foregroundStyle(Color.appWhite)
            .shadow(color: colors[colorIndex].opacity(0.9), radius: 8,  x: 0, y: 0)
            .shadow(color: colors[colorIndex].opacity(0.5), radius: 20, x: 0, y: 0)
            .shadow(color: colors[colorIndex].opacity(0.3), radius: 35, x: 0, y: 0)
            .animation(.easeInOut(duration: 1.0), value: colorIndex)
            .onAppear {
                neonTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                    withAnimation { colorIndex = (colorIndex + 1) % colors.count }
                }
            }
            .onDisappear {
                neonTimer?.invalidate()
                neonTimer = nil
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
