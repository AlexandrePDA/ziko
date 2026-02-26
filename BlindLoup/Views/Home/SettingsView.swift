import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreKitService.self) private var store

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 20) {
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
        }
    }
}
