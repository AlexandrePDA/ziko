import SwiftUI

// MARK: - Data model

private enum ScoreRowStyle {
    case accent   // pervenche — points positifs standard
    case danger   // rouge cohérent — pénalité
    case bonus    // vert sauge — bonus
    case header   // séparateur de section, pas de points
}

private struct ScoreRow {
    let label: String
    let points: String
    let style: ScoreRowStyle
}

private struct Slide {
    let emoji: String
    let title: String
    let subtitle: String
    let body: String
    var scores: [ScoreRow]? = nil
    var tip: String? = nil
    var tipEmoji: String = "💡"
}

private let slides: [Slide] = [
    Slide(
        emoji: "🎵",
        title: "BlindLoup",
        subtitle: "Bluffez vos amis",
        body: "Chaque joueur choisit des musiques en secret. Pendant la partie, tout le monde essaie de deviner à qui appartient chaque morceau."
    ),
    Slide(
        emoji: "🤫",
        title: "Sélection secrète",
        subtitle: "Étape 1",
        body: "Chacun choisit ses morceaux en secret pendant que les autres regardent ailleurs. Mélange tes vrais coups de cœur avec des pièges — plus tu brouilles les pistes, plus tu gagnes !",
        tip: "Une musique ne peut être sélectionnée qu'une fois par joueur, mais plusieurs joueurs peuvent avoir les mêmes goûts...",
        tipEmoji: "👀"
    ),
    Slide(
        emoji: "🎧",
        title: "L'écoute",
        subtitle: "Étape 2",
        body: "Tous les morceaux sont joués dans un ordre aléatoire. La pochette est visible mais l'identité du propriétaire reste secrète. Écoute, observe, déduis !"
    ),
    Slide(
        emoji: "🗳️",
        title: "Le vote",
        subtitle: "Étape 3",
        body: "Après chaque morceau, chaque joueur vote pour désigner le propriétaire. Impossible de voter pour soi-même — à toi de jouer !",
        tip: "Le propriétaire vote aussi pendant la partie pour brouiller les pistes."
    ),
    Slide(
        emoji: "🏆",
        title: "Les points",
        subtitle: "Étape 4",
        body: "Le score récompense autant les bons détectives que les grands bluffeurs.",
        scores: [
            ScoreRow(label: "Personne ne te trouve 🕵️",       points: "+30 pts", style: .accent),
            ScoreRow(label: "Tu trouves le propriétaire 🎯",    points: "+10 pts", style: .accent),
            ScoreRow(label: "Tout le monde te trouve 😬",       points: "−10 pts", style: .danger),
            ScoreRow(label: "BONUS MANCHE",                      points: "",        style: .header),
            ScoreRow(label: "Seul(e) à avoir trouvé 🔥",       points: "+20 pts", style: .bonus),
            ScoreRow(label: "BONUS PARTIE",                      points: "",        style: .header),
            ScoreRow(label: "Aucune de tes musiques trouvées ✨", points: "+20 pts", style: .bonus),
        ]
    ),
]

// MARK: - Colors

private extension ScoreRowStyle {
    var textColor: Color {
        switch self {
        case .accent:  return Color.appAccent
        case .danger:  return Color(hex: "#E86060")
        case .bonus:   return Color.scoreBonus   // vert sauge
        case .header:  return Color.appGrey
        }
    }

    var backgroundColor: Color {
        switch self {
        case .accent:  return Color.appAccent.opacity(0.12)
        case .danger:  return Color(hex: "#E86060").opacity(0.12)
        case .bonus:   return Color.scoreBonus.opacity(0.12)
        case .header:  return .clear
        }
    }
}

// MARK: - HowToPlayView

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.appBlack.ignoresSafeArea()

            TabView(selection: $currentPage) {
                ForEach(slides.indices, id: \.self) { index in
                    SlideView(slide: slides[index], isLast: index == slides.count - 1) {
                        if index < slides.count - 1 {
                            withAnimation { currentPage = index + 1 }
                        } else {
                            dismiss()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.appGrey)
            }
            .padding(.top, 56)
            .padding(.trailing, 20)
        }
    }
}

// MARK: - Single slide

private struct SlideView: View {
    let slide: Slide
    let isLast: Bool
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Big emoji
            Text(slide.emoji)
                .font(.system(size: 80))
                .padding(.bottom, 24)

            // Subtitle chip
            Text(slide.subtitle.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appOrange)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color.appOrange.opacity(0.15))
                .clipShape(Capsule())
                .padding(.bottom, 12)

            // Title
            Text(slide.title)
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(Color.appWhite)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            // Body
            Text(slide.body)
                .font(.body)
                .foregroundStyle(Color.appGrey)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)

            // Scores
            if let scores = slide.scores {
                VStack(spacing: 8) {
                    ForEach(scores, id: \.label) { row in
                        if row.style == .header {
                            // Section header "BONUS"
                            HStack {
                                Rectangle()
                                    .fill(Color.scoreBonus.opacity(0.4))
                                    .frame(height: 1)
                                Text(row.label)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.scoreBonus)
                                    .fixedSize()
                                Rectangle()
                                    .fill(Color.scoreBonus.opacity(0.4))
                                    .frame(height: 1)
                            }
                            .padding(.top, 4)
                        } else {
                            HStack(alignment: .top, spacing: 12) {
                                Text(row.label)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appWhite)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: 8)
                                Text(row.points)
                                    .font(.subheadline)
                                    .fontWeight(.black)
                                    .foregroundStyle(row.style.textColor)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(row.style.backgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
            }

            // Tip
            if let tip = slide.tip {
                HStack(spacing: 10) {
                    Text(slide.tipEmoji)
                    Text(tip)
                        .font(.caption)
                        .foregroundStyle(Color.appGrey)
                }
                .padding(12)
                .background(Color.appNavy)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 32)
                .padding(.top, 20)
            }

            Spacer()
            Spacer()

            // CTA
            PrimaryButton(title: isLast ? "C'est parti !" : "Suivant") {
                onNext()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
    }
}
