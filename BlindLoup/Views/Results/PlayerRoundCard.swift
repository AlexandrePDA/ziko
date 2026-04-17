import SwiftUI

// MARK: - RoundTitle

enum RoundTitle {
    case oreille        // 👁️ L'OREILLE ABSOLUE
    case insaisissable  // 🟢 L'INSAISISSABLE
    case finLimier      // 🕯️ LE FIN LIMIER
    case honteSupreme   // ☠️ HONTE SUPRÊME
    case sniperMiss     // 🎯 L'ANGLE MORT
    case provocateurLoss // 🃏 LA MISE PERDUE

    var emoji: String {
        switch self {
        case .oreille:          return "👁️"
        case .insaisissable:    return "🟢"
        case .finLimier:        return "🕯️"
        case .honteSupreme:     return "☠️"
        case .sniperMiss:       return "🎯"
        case .provocateurLoss:  return "🃏"
        }
    }

    var label: String {
        switch self {
        case .oreille:          return "L'OREILLE ABSOLUE"
        case .insaisissable:    return "L'INSAISISSABLE"
        case .finLimier:        return "LE FIN LIMIER"
        case .honteSupreme:     return "HONTE SUPRÊME"
        case .sniperMiss:       return "L'ANGLE MORT"
        case .provocateurLoss:  return "LA MISE PERDUE"
        }
    }

    var color: Color {
        switch self {
        case .oreille:          return Color.appAccent
        case .insaisissable:    return Color.scoreBonus
        case .finLimier:        return Color(hex: "#FF9500")
        case .honteSupreme:     return Color.scorePenalty
        case .sniperMiss:       return Color.scorePenalty
        case .provocateurLoss:  return Color.scorePenalty
        }
    }

    var sarcasm: String {
        switch self {
        case .oreille:
            return "Pendant que les autres hésitaient, lui écoutait vraiment. Ça change tout."
        case .insaisissable:
            return "Aucune trace. Aucun indice. Aucune pitié. Tu as semé tout le monde et tu le sais très bien."
        case .finLimier:
            return "Là où tout le monde a raté, il a trouvé. Seul contre tous. C'est ça, le vrai flair."
        case .honteSupreme:
            return "Tu pensais être imprévisible. Tu avais l'originalité d'un générique de supermarché. Chaque suspect du groupe t'a désigné sans hésiter. C'est beau, dans le genre catastrophique."
        case .sniperMiss:
            return "Tu avais le talent. Tu avais le rôle. Tu as juste visé à côté. C'est ça, l'angle mort."
        case .provocateurLoss:
            return "Tu as misé. Tu as perdu. C'est le jeu, mon grand. C'est littéralement le jeu."
        }
    }
}

// MARK: - Data models

struct PillData {
    let points: String
    let label: String
    let color: Color
}

struct RoundResult {
    let player: Player
    let title: RoundTitle
    let delta: Int
    let pills: [PillData]
}

// MARK: - PlayerRoundCard

struct PlayerRoundCard: View {
    let result: RoundResult
    @State private var expanded = false

    private var deltaColor: Color {
        result.delta >= 0 ? Color(hex: "#34C759") : Color(hex: "#FF3B30")
    }

    private var deltaText: String {
        let abs = abs(result.delta)
        return result.delta >= 0 ? "+\(abs) pts ↑" : "−\(abs) pts ↓"
    }

    var body: some View {
        let titleColor = result.title.color

        VStack(alignment: .leading, spacing: 0) {

            // ── Ligne 1 : nom + delta ────────────────────────────
            HStack {
                Text(result.player.name)
                    .font(.title3.weight(.black))
                    .foregroundStyle(Color.playerColor(result.player.colorIndex))
                Spacer()
                Text(deltaText)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(deltaColor)
            }

            // ── Ligne 2 : emoji + titre + chevron ────────────────
            HStack(spacing: 8) {
                Text(result.title.emoji)
                    .font(.body)
                Text(result.title.label)
                    .font(.caption.weight(.heavy))
                    .kerning(1.5)
                    .foregroundStyle(titleColor)
                Spacer()
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appGrey)
            }
            .padding(.top, 10)

            // ── Pills ─────────────────────────────────────────────
            if !result.pills.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(result.pills.indices, id: \.self) { i in
                        let pill = result.pills[i]
                        Text("\(pill.points) · \(pill.label)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(pill.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(pill.color.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.top, 10)
            }

            // ── Texte sarcastique (expanded) ─────────────────────
            if expanded {
                Divider()
                    .overlay(titleColor.opacity(0.3))
                    .padding(.top, 12)

                Text(result.title.sarcasm)
                    .font(.footnote.italic())
                    .foregroundStyle(Color.appGreyLight)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)
            }
        }
        .padding(16)
        .background(Color.appNavy)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(result.title.color.opacity(0.25), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("\(result.player.name) — \(result.title.label), \(result.delta > 0 ? "+" : "")\(result.delta) points. Appuyer pour détails.")
        .onTapGesture {
            withAnimation(.spring(duration: 0.3)) { expanded.toggle() }
        }
    }
}

// MARK: - RoundResultSection

struct RoundResultSection: View {
    let round: GameRound
    let players: [Player]
    let scoreCase: ScoreCase
    var playerRoles: [UUID: RoleType] = [:]

    private var results: [RoundResult] {
        var mainResults: [RoundResult] = players
            .compactMap { player -> RoundResult? in
                let isOwner = player.id == round.track.ownerID
                let didFind = !isOwner && round.votes[player.id] == round.track.ownerID

                // Calcul de la pill principale et du delta de base
                let base: (title: RoundTitle, delta: Int, pill: PillData)?

                switch scoreCase {
                case .nobodyFound:
                    guard isOwner else { return nil }
                    base = (
                        .insaisissable,
                        ScoringConfig.bluffSuccessPoints,
                        PillData(points: "+\(ScoringConfig.bluffSuccessPoints) pts",
                                 label: "Introuvable 🟢",
                                 color: Color.scoreBonus)
                    )

                case .soleFound:
                    guard didFind else { return nil }
                    let total = ScoringConfig.finderPoints + ScoringConfig.soleFinderBonus
                    base = (
                        .finLimier,
                        total,
                        PillData(points: "+\(total) pts",
                                 label: "Seul à trouver 🔥",
                                 color: Color(hex: "#FF9500"))
                    )

                case .multipleFound:
                    guard didFind else { return nil }
                    base = (
                        .oreille,
                        ScoringConfig.finderPoints,
                        PillData(points: "+\(ScoringConfig.finderPoints) pts",
                                 label: "A trouvé 🎯",
                                 color: Color.appAccent)
                    )

                case .everyoneFound:
                    if isOwner {
                        base = (
                            .honteSupreme,
                            -ScoringConfig.allFoundPenalty,
                            PillData(points: "−\(ScoringConfig.allFoundPenalty) pts",
                                     label: "Démasqué ☠️",
                                     color: Color.scorePenalty)
                        )
                    } else if didFind {
                        base = (
                            .oreille,
                            ScoringConfig.finderPoints,
                            PillData(points: "+\(ScoringConfig.finderPoints) pts",
                                     label: "A trouvé 🎯",
                                     color: Color.appAccent)
                        )
                    } else {
                        return nil
                    }
                }

                guard let base else { return nil }

                // Bonus de rôle (mode premium uniquement)
                let (rolePills, extraDelta) = roleBonuses(for: player,
                                                          didFind: didFind,
                                                          isOwner: isOwner)

                // Pills : affichées seulement si un bonus de rôle s'ajoute à la base.
                // En mode free (playerRoles vide), jamais de pill.
                let finalPills: [PillData] = rolePills.isEmpty ? [] : [base.pill] + rolePills

                return RoundResult(
                    player: player,
                    title: base.title,
                    delta: base.delta + extraDelta,
                    pills: finalPills
                )
            }

        // Second pass : cartes de pénalité de rôle pour les joueurs absents du premier pass
        // (Sniper raté, Provocateur mise perdue) — uniquement en mode premium (playerRoles non vide)
        if !playerRoles.isEmpty {
            let coveredIDs = Set(mainResults.map { $0.player.id })
            for player in players {
                guard !coveredIDs.contains(player.id),
                      player.id != round.track.ownerID,
                      let role = playerRoles[player.id] else { continue }

                let didFind = round.votes[player.id] == round.track.ownerID

                switch role {
                case .sniper where !didFind:
                    let penalty = ScoringConfig.sniperWrongPenalty
                    mainResults.append(RoundResult(
                        player: player,
                        title: .sniperMiss,
                        delta: -penalty,
                        pills: [PillData(
                            points: "−\(penalty) pts",
                            label: "Mauvaise accusation · Sniper 🎯",
                            color: Color.scorePenalty
                        )]
                    ))

                case .provocateur where !didFind && round.doublingVoters.contains(player.id):
                    let penalty = ScoringConfig.finderPoints * ScoringConfig.provocateurMultiplier
                    mainResults.append(RoundResult(
                        player: player,
                        title: .provocateurLoss,
                        delta: -penalty,
                        pills: [PillData(
                            points: "−\(penalty) pts",
                            label: "Mise doublée — perdue 🃏",
                            color: Color.scorePenalty
                        )]
                    ))

                default:
                    break
                }
            }
        }

        return mainResults.sorted { a, b in
            // HONTE SUPRÊME toujours en premier
            if a.title == .honteSupreme { return true }
            if b.title == .honteSupreme { return false }
            return a.delta > b.delta
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(results, id: \.player.id) { result in
                PlayerRoundCard(result: result)
            }
        }
    }

    // MARK: - Role bonus pills

    private func roleBonuses(for player: Player, didFind: Bool, isOwner: Bool) -> (pills: [PillData], extraDelta: Int) {
        guard !isOwner, let role = playerRoles[player.id] else { return ([], 0) }

        var pills: [PillData] = []
        var extra = 0

        switch role {
        case .sniper:
            if didFind {
                let bonus = ScoringConfig.finderPoints
                pills.append(PillData(
                    points: "+\(bonus) pts",
                    label: "Bonus Sniper ×2 🎯",
                    color: RoleType.sniper.accentColor
                ))
                extra += bonus
            } else {
                let penalty = ScoringConfig.sniperWrongPenalty
                pills.append(PillData(
                    points: "−\(penalty) pts",
                    label: "Mauvaise accusation · Sniper 🎯",
                    color: Color.scorePenalty
                ))
                extra -= penalty
            }

        case .provocateur:
            if round.doublingVoters.contains(player.id) {
                if didFind {
                    let bonus = ScoringConfig.finderPoints
                    pills.append(PillData(
                        points: "+\(bonus) pts",
                        label: "Mise doublée — gagné 🃏",
                        color: RoleType.provocateur.accentColor
                    ))
                    extra += bonus
                } else {
                    let penalty = ScoringConfig.finderPoints * ScoringConfig.provocateurMultiplier
                    pills.append(PillData(
                        points: "−\(penalty) pts",
                        label: "Mise doublée — perdue 🃏",
                        color: Color.scorePenalty
                    ))
                    extra -= penalty
                }
            }

        default:
            break
        }

        return (pills, extra)
    }
}
