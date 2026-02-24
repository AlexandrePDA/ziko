import SwiftUI

struct ClassicModeMenuView: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(StoreKitService.self) private var store

    @State private var showHowToPlay   = false
    @State private var showHistory     = false
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
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // ── Illustration animée ───────────────────────────
                ClassicIllustration()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                // ── Title ─────────────────────────────────────────
                VStack(spacing: 6) {
                    Text("Classique")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(Color.appWhite)
                    Text("Devine à qui appartient chaque morceau.\nVote, bluff et marque des points.")
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
                            Image(systemName: "play.fill")
                                .font(.headline)
                            Text("Jouer")
                                .font(.headline.weight(.bold))
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color.appBackground)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(Color.appAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)

                    // Comment jouer
                    Button(action: { showHowToPlay = true }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .font(.headline)
                            Text("Comment jouer ?")
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

                    // Historique (premium)
                    Button(action: {
                        store.isPremium ? (showHistory = true) : (showPremiumSheet = true)
                    }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.headline)
                            Text("Historique")
                                .font(.headline)
                            Spacer()
                            if !store.isPremium {
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
                        .foregroundStyle(store.isPremium ? Color.appWhite : Color.appGrey)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(Color.appSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showHowToPlay)    { HowToPlayView() }
        .sheet(isPresented: $showHistory)      { GameHistoryView() }
        .sheet(isPresented: $showPremiumSheet) { PremiumPaywallView() }
    }
}
