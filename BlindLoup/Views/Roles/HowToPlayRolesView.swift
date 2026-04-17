import SwiftUI

// MARK: - Data

private struct RolesSlide {
    let emoji: String
    let title: String
    let body: String
    var note: String? = nil
    var noteEmoji: String = "💡"
    var accentColor: Color = Color.appAccent
    var ctaLabel: String? = nil
}

private let rolesSlides: [RolesSlide] = [
    RolesSlide(
        emoji: "🔍",
        title: "Le concept",
        body: "Tes amis pensent te connaître.\nProuve-leur qu'ils ont tort.\n\nAliiibi, c'est le jeu où l'on partage ses musiques, en toute discrétion… et où l'on tente de griller celles des autres."
    ),
    RolesSlide(
        emoji: "🎧",
        title: "Comment jouer",
        body: "Chaque joueur choisit ses musiques en secret. La playlist démarre. Et là, le jeu commence vraiment.\n\nÉcoute. Analyse. Accuse.\n(Ou bluffe. On ne juge pas.)"
    ),
    RolesSlide(
        emoji: "🏆",
        title: "Les points",
        body: "Tu grilles quelqu'un → tu marques des points.\nPersonne ne te grille → tu marques des points.\nTu te fais griller par tout le monde → tu mérites ce qui t'arrive.",
        note: "À chaque révélation, tu hérites d'un titre. Certains font rêver. Certains font honte. Tous sont mérités.",
        noteEmoji: "🏅"
    ),
    RolesSlide(
        emoji: "🕵️",
        title: "Mode ALIIIBI+ : les rôles",
        body: "Le mode Enquête change tout.\n\nAvant même que la musique commence, certains joueurs reçoivent une mission secrète. Un rôle. Des règles connues d'eux seuls.",
        note: "Certains sont là pour bluffer. D'autres pour piéger. D'autres encore… pour souffrir.\nTu sauras lequel tu es. Les autres, jamais — jusqu'à la fin.",
        noteEmoji: "🕵️",
        accentColor: Color.playerColor(1)
    ),
    RolesSlide(
        emoji: "🚀",
        title: "Arrête de lire",
        body: "Lance une partie.\n\nTes amis t'attendent…\net ils ont déjà des soupçons.",
        ctaLabel: "C'est parti !"
    ),
]

// MARK: - HowToPlayRolesView

struct HowToPlayRolesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.appBlack.ignoresSafeArea()

            TabView(selection: $currentPage) {
                ForEach(rolesSlides.indices, id: \.self) { index in
                    RolesSlideView(
                        slide: rolesSlides[index],
                        isLast: index == rolesSlides.count - 1
                    ) {
                        if index < rolesSlides.count - 1 {
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

            // Bouton fermer
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.appGrey)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Fermer")
            .padding(.top, 44)
            .padding(.trailing, 12)
        }
    }
}

// MARK: - RolesSlideView

private struct RolesSlideView: View {
    let slide: RolesSlide
    let isLast: Bool
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(slide.emoji)
                .font(.system(size: 72))
                .padding(.bottom, 28)

            Text(slide.title)
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(Color.appWhite)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
                .padding(.horizontal, 32)

            Text(slide.body)
                .font(.body)
                .foregroundStyle(Color.appGreyLight)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)

            if let note = slide.note {
                HStack(alignment: .top, spacing: 10) {
                    Text(slide.noteEmoji)
                        .font(.body)
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(Color.appGreyLight)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .background(slide.accentColor.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(slide.accentColor.opacity(0.2), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 32)
                .padding(.top, 24)
            }

            Spacer()
            Spacer()

            Button(action: onNext) {
                Text(slide.ctaLabel ?? (isLast ? "C'est parti !" : "Suivant"))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appPremiumGold)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
    }
}
