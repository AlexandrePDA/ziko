import SwiftUI

struct RolesMenuView: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(StoreKitService.self) private var store

    @State private var showHowToPlay    = false
    @State private var showHistory      = false
    @State private var showPremiumSheet = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Top bar ───────────────────────────────────────
                HStack {
                    Button(action: { vm.phase = .home }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Retour")
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.appGrey)
                        .frame(minHeight: 44)
                    }
                    .accessibilityLabel("Retour à l'accueil")
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // ── Illustration animée ───────────────────────────
                RolesMenuIllustration()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                // ── Title ─────────────────────────────────────────
                VStack(spacing: 6) {
                    Text("Rôles Secrets")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(Color.appWhite)
                    Text("Chaque joueur reçoit un rôle secret.\nAccomplis ta mission pour décrocher le bonus.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appGrey)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                .padding(.bottom, 28)

                Spacer()

                // ── Menu items ────────────────────────────────────
                VStack(spacing: 14) {

                    // Jouer
                    Button(action: { vm.advancePhase() }) {
                        HStack {
                            Image(systemName: "play.fill").font(.headline)
                            Text("Jouer").font(.headline.weight(.bold))
                            Spacer()
                            Image(systemName: "arrow.right").font(.subheadline)
                        }
                        .foregroundStyle(Color.appBackground)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(Color.playerColor(1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)

                    // Comment jouer
                    Button(action: { showHowToPlay = true }) {
                        menuRow(icon: "questionmark.circle", label: "Comment jouer ?")
                    }
                    .buttonStyle(.plain)

                    // Historique (premium)
                    Button(action: {
                        store.isPremium ? (showHistory = true) : (showPremiumSheet = true)
                    }) {
                        menuRow(icon: "clock.arrow.circlepath", label: "Historique", locked: !store.isPremium)
                    }
                    .buttonStyle(.plain)

                    // Les rôles
                    RolesLegendButton()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showHowToPlay)    { HowToPlayRolesView() }
        .sheet(isPresented: $showHistory)      { GameHistoryView() }
        .sheet(isPresented: $showPremiumSheet) { PremiumPaywallView() }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: StorageKeys.hasSeenRolesTutorial) {
                showHowToPlay = true
                UserDefaults.standard.set(true, forKey: StorageKeys.hasSeenRolesTutorial)
            }
        }
    }

    @ViewBuilder
    private func menuRow(icon: String, label: String, locked: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.headline)
            Text(label)
                .font(.headline)
            Spacer()
            if locked {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 9))
                    Text("PREMIUM")
                        .font(.system(size: 10, weight: .black))
                }
                .foregroundStyle(Color.appBackground)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.appAccent)
                .clipShape(Capsule())
            } else {
                Image(systemName: "arrow.right")
                    .font(.subheadline)
            }
        }
        .foregroundStyle(locked ? Color.appGrey : Color.appWhite)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Roles legend button + sheet

private struct RolesLegendButton: View {
    @State private var showLegend = false

    var body: some View {
        Button(action: { showLegend = true }) {
            HStack {
                Image(systemName: "theatermasks")
                    .font(.headline)
                Text("Les rôles")
                    .font(.headline)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.subheadline)
            }
            .foregroundStyle(Color.appWhite)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showLegend) { RolesLegendeView() }
    }
}

// MARK: - Roles legend sheet (also used in FinalScoreView)

struct RolesLegendeView: View {
    @Environment(\.dismiss) private var dismiss

    private let roles: [RoleType] = RoleType.allCases

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBlack.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Chaque joueur reçoit un rôle en secret au début de la partie. Accomplis ta mission pour décrocher un bonus.")
                            .font(.subheadline)
                            .foregroundStyle(Color.appGreyLight)
                            .lineSpacing(4)
                            .padding(.top, 8)

                        ForEach(roles, id: \.rawValue) { role in
                            RoleLegendRow(role: role)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Les rôles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }
}

private struct RoleLegendRow: View {
    let role: RoleType

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(role.emoji)
                .font(.title2)
                .frame(width: 36, alignment: .center)

            VStack(alignment: .leading, spacing: 4) {
                Text(role.title)
                    .font(.caption)
                    .fontWeight(.black)
                    .kerning(1.2)
                    .foregroundStyle(role.accentColor)
                Text(role.mission)
                    .font(.caption)
                    .foregroundStyle(Color.appGreyLight)
                    .fixedSize(horizontal: false, vertical: true)
                Text(role.bonusLabel)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(role.accentColor.opacity(0.8))
                    .padding(.top, 2)
            }
            Spacer()
        }
        .padding(14)
        .background(role.accentColor.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(role.accentColor.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Roles menu illustration

struct RolesMenuIllustration: View {
    @State private var animate = false

    private let roleEmojis: [(String, CGFloat, CGFloat)] = [
        ("🕵️", -90, -30),
        ("🔎",  85, -40),
        ("🎯", -60,  40),
        ("🃏",  70,  35),
        ("😇", -10, -55),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1A0A2E"), Color.appSurface],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.playerColor(1).opacity(0.4))
                .frame(width: 100)
                .blur(radius: 24)
                .offset(x: -60, y: -20)
            Circle()
                .fill(Color.playerColor(4).opacity(0.3))
                .frame(width: 80)
                .blur(radius: 18)
                .offset(x: 70, y: 30)

            ForEach(Array(roleEmojis.enumerated()), id: \.offset) { idx, item in
                Text(item.0)
                    .font(.system(size: 28))
                    .offset(x: item.1, y: item.2 + (animate ? -5 : 5))
                    .opacity(0.85)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
                            .delay(Double(idx) * 0.35),
                        value: animate
                    )
            }

            Text("🐺")
                .font(.system(size: 62))
                .shadow(color: Color.playerColor(1).opacity(0.8), radius: 16)
                .scaleEffect(animate ? 1.05 : 0.96)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}
