import SwiftUI

struct PremiumPaywallView: View {
    @Environment(StoreKitService.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            VStack(spacing: 0) {
                // Close
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appGrey)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                // Icon
                Image(systemName: "crown.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.appOrange)
                    .padding(.bottom, 16)

                Text("BlindLoup Premium")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(Color.appWhite)
                    .padding(.bottom, 8)

                Text("Achat unique, à vie")
                    .font(.subheadline)
                    .foregroundStyle(Color.appGrey)
                    .padding(.bottom, 32)

                // Features
                VStack(spacing: 16) {
                    FeatureRow(icon: "gamecontroller.fill",
                               text: "Tous les modes de jeu")
                    FeatureRow(icon: "person.3.fill",
                               text: "Jusqu'à 8 joueurs (vs 4 en gratuit)")
                    FeatureRow(icon: "music.note.list",
                               text: "Jusqu'à 6 morceaux par joueur")
                    FeatureRow(icon: "clock.fill",
                               text: "Historique des parties")
                    FeatureRow(icon: "crown.fill",
                               text: "Soutenir le développement")
                }
                .padding(.horizontal, 32)

                Spacer()

                // CTA
                VStack(spacing: 12) {
                    if store.isLoading {
                        ProgressView().tint(Color.appOrange)

                    } else if store.isLoadingProducts {
                        VStack(spacing: 8) {
                            ProgressView().tint(Color.appOrange)
                            Text("Chargement…")
                                .font(.caption).foregroundStyle(Color.appGrey)
                        }

                    } else if store.isProductAvailable {
                        PrimaryButton(title: "Débloquer Premium") {
                            Task { try? await store.purchasePremium() }
                        }
                        Button("Restaurer les achats") {
                            Task { try? await store.restorePurchases() }
                        }
                        .font(.subheadline).foregroundStyle(Color.appGrey)

                    } else {
                        // Produit non disponible — affiche l'erreur + réessayer
                        if let error = store.errorMessage {
                            Text(error)
                                .font(.caption).foregroundStyle(Color.appGrey)
                                .multilineTextAlignment(.center)
                        }
                        Button(action: { Task { await store.loadProducts() } }) {
                            Text("Réessayer")
                                .font(.headline).foregroundStyle(Color.appOrange)
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appOrange, lineWidth: 1.5))
                        }
                        #if DEBUG
                        Button(action: { store.activatePremiumForTesting() }) {
                            Text("Simuler Premium (debug)")
                                .font(.caption).foregroundStyle(Color.appGrey)
                        }
                        #endif
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            Task { await store.loadProducts() }
        }
        .onChange(of: store.isPremium) { _, newValue in
            if newValue { dismiss() }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(Color.appOrange)
            Text(text)
                .foregroundStyle(Color.appWhite)
            Spacer()
        }
    }
}
