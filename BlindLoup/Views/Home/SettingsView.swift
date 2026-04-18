import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreKitService.self) private var store
    @Environment(SoundService.self) private var sound
    @State private var showPlanDetail = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 12) {
                    // App version row
                    HStack {
                        Label("Version", systemImage: "info.circle")
                            .foregroundStyle(Color.appWhite)
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(Color.appGrey)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.appSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Sound row
                    HStack {
                        Label("Sons", systemImage: sound.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .foregroundStyle(Color.appWhite)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { !sound.isMuted },
                            set: { sound.isMuted = !$0 }
                        ))
                        .tint(Color.appAccent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.appSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 20)

                    // Plan row
                    Group {
                        if store.isPremium {
                            Button(action: { showPlanDetail = true }) {
                                HStack {
                                    Label("Plan", systemImage: "crown.fill")
                                        .foregroundStyle(Color.appWhite)
                                    Spacer()
                                    HStack(spacing: 5) {
                                        Text("👑")
                                            .font(.system(size: 12))
                                        Text("ALIIIBI+")
                                            .font(.caption.weight(.bold))
                                    }
                                    .foregroundStyle(Color.appPremiumGold)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.appGrey)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.appSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        } else {
                            HStack {
                                Label("Plan", systemImage: "crown")
                                    .foregroundStyle(Color.appWhite)
                                Spacer()
                                Text("Gratuit")
                                    .foregroundStyle(Color.appGrey)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.appSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal, 20)

                    #if DEBUG
                    VStack(spacing: 10) {
                        Text("DEBUG")
                            .font(.caption)
                            .foregroundStyle(Color.appGrey)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)

                        Button(action: { store.activatePremiumForTesting() }) {
                            Label("Activer Premium", systemImage: "crown.fill")
                                .foregroundStyle(Color.appAccent)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(Color.appSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 20)

                        Button(action: { store.deactivatePremiumForTesting() }) {
                            Label("Désactiver Premium", systemImage: "crown")
                                .foregroundStyle(Color.appGrey)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(Color.appSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 20)
                    }
                    #endif

                    Spacer()

                    // ── Logo ─────────────────────────────────────
                    VStack(spacing: 8) {
                        if let uiImage = UIImage(named: "AppIcon") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        NeonTitleView(size: 18)
                        Text("Le jeu qui détruit des amitiés. Mais en rythme.")
                            .font(.caption)
                            .foregroundStyle(Color.appGrey)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                }
            }
            .sheet(isPresented: $showPlanDetail) { PlanDetailView() }
        }
    }
}

// MARK: - Plan detail sheet (ALIIIBI+)

private struct PlanDetailView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appGrey)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Fermer")
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                Text("👑")
                    .font(.system(size: 56))
                    .padding(.bottom, 12)

                Text("ALIIIBI+")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(Color.appPremiumGold)
                    .padding(.bottom, 4)

                Text("Achat unique, à vie")
                    .font(.subheadline)
                    .foregroundStyle(Color.appGrey)
                    .padding(.bottom, 36)

                VStack(spacing: 16) {
                    PlanFeatureRow(icon: "person.3.fill", text: "Jusqu'à 8 joueurs")
                    PlanFeatureRow(icon: "music.note.list", text: "Jusqu'à 6 morceaux par joueur")
                    PlanFeatureRow(icon: "theatermasks.fill", text: "Mode infiltré — rôles secrets")
                    PlanFeatureRow(icon: "clock.fill", text: "Historique des parties")
                    PlanFeatureRow(icon: "crown.fill", text: "Soutenir le développement")
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
    }
}

private struct PlanFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(Color.appPremiumGold)
            Text(text)
                .foregroundStyle(Color.appWhite)
            Spacer()
        }
    }
}
