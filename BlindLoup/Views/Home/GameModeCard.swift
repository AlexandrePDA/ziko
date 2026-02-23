import SwiftUI

// MARK: - Card

struct GameModeCard: View {
    let mode: GameModeCard.Mode
    let isPremium: Bool
    let onTap: () -> Void

    enum Mode {
        case classic, roles
        var title: String     { self == .classic ? "Classique"    : "Loup-Garou" }
        var subtitle: String  { self == .classic ? "Le blind test" : "Rôles secrets" }
        var description: String {
            self == .classic
                ? "Devine à qui appartient chaque morceau. Vote, bluff et marque des points."
                : "Chaque joueur reçoit un rôle secret avec une mission qui change la partie."
        }
        var accentColor: Color {
            self == .classic ? Color.playerColor(3) : Color.playerColor(1)
        }
        var requiresPremium: Bool { self == .roles }
    }

    var locked: Bool { mode.requiresPremium && !isPremium }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Illustration
                ZStack {
                    if mode == .classic {
                        ClassicIllustration()
                    } else {
                        RolesIllustration()
                    }

                    // Premium badge
                    if locked {
                        VStack {
                            HStack {
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 9))
                                    Text("PREMIUM")
                                        .font(.system(size: 10, weight: .black))
                                }
                                .foregroundStyle(Color.appBackground)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 5)
                                .background(Color.appAccent)
                                .clipShape(Capsule())
                                .padding(12)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 150)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 20, bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0, topTrailingRadius: 20
                ))

                // Info bar
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(mode.title)
                                .font(.headline)
                                .fontWeight(.black)
                                .foregroundStyle(Color.appWhite)
                            if locked {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color.appGrey)
                            }
                        }
                        Text(mode.description)
                            .font(.caption)
                            .foregroundStyle(Color.appGrey)
                            .lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: locked ? "lock.fill" : "arrow.right")
                        .font(.subheadline)
                        .foregroundStyle(locked ? Color.appGrey : mode.accentColor)
                        .padding(10)
                        .background((locked ? Color.appGrey : mode.accentColor).opacity(0.15))
                        .clipShape(Circle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.appSurface)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 0, bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20, topTrailingRadius: 0
                ))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Classic illustration

private struct ClassicIllustration: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            // Fond dégradé
            LinearGradient(
                colors: [Color(hex: "#0D1B3E"), Color.appSurface],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            // Blobs colorés flous
            Circle()
                .fill(Color.playerColor(3).opacity(0.35))
                .frame(width: 90)
                .blur(radius: 20)
                .offset(x: -70, y: -20)
            Circle()
                .fill(Color.playerColor(0).opacity(0.3))
                .frame(width: 70)
                .blur(radius: 16)
                .offset(x: 80, y: 10)
            Circle()
                .fill(Color.playerColor(2).opacity(0.25))
                .frame(width: 55)
                .blur(radius: 14)
                .offset(x: 20, y: 40)

            // Notes flottantes
            ForEach(Array([("♪", -80.0, -30.0, 0), ("♫", 75.0, -20.0, 2),
                           ("♩", -40.0, 38.0, 4), ("♬", 55.0, 35.0, 1)].enumerated()), id: \.offset) { idx, note in
                Text(note.0)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.playerColor(note.3).opacity(0.9))
                    .offset(x: note.1, y: note.2 + (animate ? -5 : 5))
                    .animation(
                        .easeInOut(duration: 2.2).repeatForever(autoreverses: true)
                            .delay(Double(idx) * 0.4),
                        value: animate
                    )
            }

            // Icône principale
            Image(systemName: "headphones")
                .font(.system(size: 52, weight: .thin))
                .foregroundStyle(Color.appWhite.opacity(0.9))
                .shadow(color: Color.playerColor(3).opacity(0.6), radius: 12)
        }
        .onAppear { animate = true }
    }
}

// MARK: - Roles illustration

private struct RolesIllustration: View {
    @State private var animate = false

    private let cards: [(Color, Double, CGSize)] = [
        (Color.playerColor(0), -18, CGSize(width: -75, height: 5)),
        (Color.playerColor(3),  12, CGSize(width:  75, height: -5)),
        (Color.playerColor(2),  -4, CGSize(width:  20, height: 30)),
        (Color.playerColor(4), -28, CGSize(width: -35, height: -20)),
    ]

    var body: some View {
        ZStack {
            // Fond dégradé violet
            LinearGradient(
                colors: [Color(hex: "#1A0A2E"), Color.appSurface],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            // Blobs
            Circle()
                .fill(Color.playerColor(1).opacity(0.4))
                .frame(width: 80)
                .blur(radius: 20)
                .offset(x: -60, y: -15)
            Circle()
                .fill(Color.playerColor(4).opacity(0.25))
                .frame(width: 60)
                .blur(radius: 14)
                .offset(x: 65, y: 25)

            // Cartes de rôles
            ForEach(cards.indices, id: \.self) { i in
                let card = cards[i]
                RoundedRectangle(cornerRadius: 5)
                    .fill(card.0.opacity(0.75))
                    .frame(width: 30, height: 42)
                    .overlay(
                        Image(systemName: "questionmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white.opacity(0.85))
                    )
                    .rotationEffect(.degrees(card.1))
                    .offset(card.2)
                    .offset(y: animate ? -3 : 3)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.3),
                        value: animate
                    )
            }

            // Loup central
            Text("🐺")
                .font(.system(size: 58))
                .shadow(color: Color.playerColor(1).opacity(0.7), radius: 14)
                .scaleEffect(animate ? 1.04 : 0.97)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animate)

            // Étoiles
            ForEach([(-50.0, -38.0), (55.0, -32.0), (-15.0, 42.0), (45.0, 38.0)], id: \.0) { x, y in
                Text("✦")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.appWhite.opacity(0.45))
                    .offset(x: x, y: y)
            }
        }
        .onAppear { animate = true }
    }
}
