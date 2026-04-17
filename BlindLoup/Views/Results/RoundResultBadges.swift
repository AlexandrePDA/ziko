import SwiftUI

// MARK: - ScoreCase

/// Résultat d'une manche selon les votes. Défini ici car utilisé par la factory et RevealView.
enum ScoreCase {
    case nobodyFound, everyoneFound, soleFound, multipleFound
}

// MARK: - Badge model

struct RoundBadge: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let playerName: String
    let playerColor: Color
    let factual: String
    let sarcastic: String
    let accentColor: Color
}

// MARK: - Factory

enum RoundBadgeFactory {
    static func badges(scoreCase: ScoreCase, owner: Player, soleDetective: Player?) -> [RoundBadge] {
        switch scoreCase {
        case .nobodyFound:
            return [insaisissable(owner: owner)]
        case .everyoneFound:
            return [honteSupreme(owner: owner)]
        case .soleFound:
            guard let detective = soleDetective else { return [] }
            return [finLimier(detective: detective)]
        case .multipleFound:
            return []
        }
    }

    private static func insaisissable(owner: Player) -> RoundBadge {
        RoundBadge(
            emoji: "🟢",
            title: "L'INSAISISSABLE",
            playerName: owner.name,
            playerColor: .playerColor(owner.colorIndex),
            factual: "Personne n'a trouvé ta musique",
            sarcastic: "Aucune trace. Aucun indice. Aucune pitié. Tu as semé tout le monde et tu le sais très bien.",
            accentColor: .green
        )
    }

    private static func honteSupreme(owner: Player) -> RoundBadge {
        RoundBadge(
            emoji: "☠️",
            title: "HONTE SUPRÊME",
            playerName: owner.name,
            playerColor: .playerColor(owner.colorIndex),
            factual: "Tout le monde a trouvé ta musique",
            sarcastic: "Tu pensais être imprévisible. Tu avais l'originalité d'un générique de supermarché. Chaque suspect du groupe t'a désigné sans hésiter. C'est beau, dans le genre catastrophique.",
            accentColor: .red
        )
    }

    private static func finLimier(detective: Player) -> RoundBadge {
        RoundBadge(
            emoji: "🕯️",
            title: "LE FIN LIMIER",
            playerName: detective.name,
            playerColor: .playerColor(detective.colorIndex),
            factual: "Seul à avoir trouvé le propriétaire",
            sarcastic: "Là où tout le monde a raté, il a trouvé. Seul contre tous. C'est ça, le vrai flair.",
            accentColor: Color.appOrange
        )
    }
}

// MARK: - ResultBadge (tap-to-expand)

struct ResultBadge: View {
    let badge: RoundBadge
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            collapseRow
            if expanded { expandedContent }
        }
        .background(badge.accentColor.opacity(0.10))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(badge.accentColor.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var collapseRow: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) { expanded.toggle() }
        } label: {
            HStack(spacing: 10) {
                Text(badge.emoji)
                    .font(.body)
                Text(badge.title)
                    .font(.caption)
                    .fontWeight(.black)
                    .kerning(1.5)
                    .foregroundStyle(badge.accentColor)
                Text("·")
                    .foregroundStyle(Color.appGrey)
                Text(badge.playerName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(badge.playerColor)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appGrey)
                    .rotationEffect(.degrees(expanded ? 180 : 0))
                    .animation(.spring(duration: 0.3), value: expanded)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .background(badge.accentColor.opacity(0.2))
                .padding(.horizontal, 14)
            Text(badge.factual)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appGreyLight)
                .padding(.horizontal, 14)
            Text(badge.sarcastic)
                .font(.caption)
                .italic()
                .foregroundStyle(Color.appGrey)
                .lineSpacing(3)
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

// MARK: - RoundResultBadges

struct RoundResultBadges: View {
    let badges: [RoundBadge]

    var body: some View {
        if !badges.isEmpty {
            VStack(spacing: 10) {
                ForEach(badges) { ResultBadge(badge: $0) }
            }
        }
    }
}

// MARK: - LegendeView

struct LegendeView: View {
    @Environment(\.dismiss) private var dismiss

    private struct LegendEntry {
        let emoji: String
        let title: String
        let condition: String
        let color: Color
        let isEndGame: Bool
    }

    private let entries: [LegendEntry] = [
        LegendEntry(emoji: "🟢", title: "L'INSAISISSABLE",
                    condition: "Personne n'a trouvé ta musique. Aucune trace. Aucun indice. Aucune pitié. Tu as semé tout le monde et tu le sais très bien.",
                    color: .green, isEndGame: false),
        LegendEntry(emoji: "🕯️", title: "LE FIN LIMIER",
                    condition: "Là où tout le monde a raté, lui a trouvé. Seul contre tous. C'est ça, le vrai flair.",
                    color: Color.appOrange, isEndGame: false),
        LegendEntry(emoji: "👁️", title: "L'OREILLE ABSOLUE",
                    condition: "Pendant que les autres hésitaient, lui écoutait vraiment. Ça change tout.",
                    color: Color.appAccent, isEndGame: false),
        LegendEntry(emoji: "☠️", title: "HONTE SUPRÊME",
                    condition: "Tout le monde a trouvé ta musique... Tu pensais être imprévisible. Tu avais l'originalité d'un générique de supermarché. Chaque suspect du groupe t'a désigné sans hésiter. C'est beau, dans le genre catastrophique.",
                    color: .red, isEndGame: false),
        LegendEntry(emoji: "⚫", title: "LE CRIME PARFAIT",
                    condition: "Personne n'a trouvé AUCUNE de tes musiques. Toute la partie. Sans une seule fausse note. L'affaire est classée — sans suite, sans suspect, sans toi. Chef-d'œuvre.",
                    color: Color.appGreyLight, isEndGame: true),
        LegendEntry(emoji: "🔵", title: "L'INSPECTEUR IMPLACABLE",
                    condition: "Tu as trouvé le plus de musiques. Pendant que les autres écoutaient, toi tu analysais. Chaque morceau était un indice. Chaque indice, une condamnation.",
                    color: Color.appAccent, isEndGame: true),
        LegendEntry(emoji: "🟣", title: "LE TÉMOIN GÊNANT",
                    condition: "Tu as tout trouvé toutes les musiques d’un joueur. Tu sais. Il sait que tu sais. Tout le monde sait que tu sais. Ambiance.",
                    color: .purple, isEndGame: true),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBlack.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Chaque morceau révélé peut déclencher un titre. Certains font rêver. D'autres font honte. Tous sont mérités.")
                            .font(.subheadline)
                            .foregroundStyle(Color.appGreyLight)
                            .lineSpacing(4)
                            .padding(.top, 8)

                        legendSection(title: "TITRES DU TOUR",    entries: entries.filter { !$0.isEndGame })
                        legendSection(title: "TITRES DE FIN DE PARTIE", entries: entries.filter { $0.isEndGame })
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Les titres")
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

    @ViewBuilder
    private func legendSection(title: String, entries: [LegendEntry]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .fontWeight(.black)
                .kerning(1.5)
                .foregroundStyle(Color.appGrey)
            ForEach(entries, id: \.title) { legendRow($0) }
        }
    }

    private func legendRow(_ entry: LegendEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(entry.emoji)
                .font(.body)
                .frame(width: 28, alignment: .center)
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title)
                    .font(.caption)
                    .fontWeight(.black)
                    .kerning(1.5)
                    .foregroundStyle(entry.color)
                Text(entry.condition)
                    .font(.caption)
                    .foregroundStyle(Color.appGreyLight)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(12)
        .background(entry.color.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(entry.color.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
