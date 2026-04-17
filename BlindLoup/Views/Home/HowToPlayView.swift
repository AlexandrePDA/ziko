import SwiftUI

// MARK: - Data

private struct Slide {
    let emoji: String
    let title: String
    let body: String
    var note: String? = nil
    var noteEmoji: String = "💡"
    var ctaLabel: String? = nil   // surcharge du bouton si besoin
}

private let welcomeSlide = Slide(
    emoji: "👋",
    title: "Bienvenue",
    body: "Bienvenue sur Aliiibi !\n\nProuve à tes amis qu'ils ne te connaissent pas autant qu'ils le croient.\n\nCi-dessous, quelques infos pour bien démarrer.",
    ctaLabel: "Suivant"
)

private let slides: [Slide] = [
    Slide(
        emoji: "🔍",
        title: "Le concept",
        body: "Tes amis pensent te connaître.\nProuve-leur qu'ils ont tort.\n\nAliiibi, c'est le jeu où l'on partage ses musiques, en toute discrétion… et où l'on tente de griller celles des autres."
    ),
    Slide(
        emoji: "🎧",
        title: "Comment jouer",
        body: "Chaque joueur choisit ses musiques en secret. La playlist démarre. Et là, le jeu commence vraiment.\n\nÉcoute. Analyse. Accuse.\n(Ou bluffe. On ne juge pas.)"
    ),
    Slide(
        emoji: "🏆",
        title: "Les points",
        body: "Tu grilles quelqu'un → tu marques des points.\nPersonne ne te grille → tu marques des points.\nTu te fais griller par tout le monde → tu mérites ce qui t'arrive.",
        note: "À chaque révélation, tu hérites d'un titre. Certains font rêver. Certains font honte. Tous sont mérités.",
        noteEmoji: "🏅"
    ),
    Slide(
        emoji: "🚀",
        title: "Arrête de lire",
        body: "Lance une partie.\n\nTes amis t'attendent…\net ils ont déjà des soupçons.",
        ctaLabel: "C'est parti !"
    ),
]

// MARK: - HowToPlayView

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    var isOnboarding: Bool = false

    private var displayedSlides: [Slide] {
        isOnboarding ? [welcomeSlide] + slides : slides
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.appBlack.ignoresSafeArea()

            TabView(selection: $currentPage) {
                ForEach(displayedSlides.indices, id: \.self) { index in
                    SlideView(
                        slide: displayedSlides[index],
                        isLast: index == displayedSlides.count - 1
                    ) {
                        if index < displayedSlides.count - 1 {
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

// MARK: - SlideView

private struct SlideView: View {
    let slide: Slide
    let isLast: Bool
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Emoji
            Text(slide.emoji)
                .font(.system(size: 72))
                .padding(.bottom, 28)

            // Titre
            Text(slide.title)
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(Color.appWhite)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
                .padding(.horizontal, 32)

            // Corps
            Text(slide.body)
                .font(.body)
                .foregroundStyle(Color.appGreyLight)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)

            // Note (ex. "titres")
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
                .background(Color.appSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 32)
                .padding(.top, 24)
            }

            Spacer()
            Spacer()

            // CTA
            PrimaryButton(title: slide.ctaLabel ?? (isLast ? "C'est parti !" : "Suivant")) {
                onNext()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
    }
}
