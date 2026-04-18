import SwiftUI
import UIKit

// MARK: - PodiumGroup

private struct PodiumGroup: Identifiable {
    let id = UUID()
    let rank: Int
    let players: [Player]
    let score: Int
}

// MARK: - FinalScoreView

struct FinalScoreView: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var titleVisible = false
    @State private var thirdVisible = false
    @State private var secondVisible = false
    @State private var firstVisible = false
    @State private var bonusVisible = false
    @State private var confettiVisible = false
    @State private var burstID: UUID? = nil
    @State private var selectedGroup: PodiumGroup? = nil
    @State private var showRolesLegend = false

    // MARK: Computed

    private var ranking: [Player] { vm.finalRanking }

    private var podiumGroups: [PodiumGroup] {
        ranking.prefix(3).enumerated().map { idx, player in
            PodiumGroup(rank: idx + 1, players: [player], score: player.score)
        }
    }

    private var rest: [Player] { Array(ranking.dropFirst(3)) }
    private var restStartRank: Int { podiumGroups.count + 1 }

    private var invincibilityWinners: [Player] { vm.invincibilityWinners }
    private var topDetectiveWinners: [Player] { vm.topDetectiveWinners }
    private var stalkerWinners: [Player] { vm.stalkerWinners }
    private var displayedBonuses: [GameViewModel.RoleBonus] {
        vm.roleBonusResults.filter { $0.role != .sniper && $0.role != .provocateur }
    }
    private var hasEndGameBonuses: Bool {
        !invincibilityWinners.isEmpty || !topDetectiveWinners.isEmpty || !stalkerWinners.isEmpty
    }
    private var hasRoleBonuses: Bool { !displayedBonuses.isEmpty }
    private var hasBonuses: Bool { hasEndGameBonuses || hasRoleBonuses }
    private var firstPlaceColor: Color {
        podiumGroups.first?.players.first.map { Color.playerColor($0.colorIndex) }
            ?? Color(hex: "#EDD88A")
    }

    // MARK: Body

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            if firstVisible {
                RadialGradient(
                    gradient: Gradient(colors: [firstPlaceColor.opacity(0.10), Color.clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 300
                )
                .ignoresSafeArea()
                .transition(.opacity)
                .animation(.easeIn(duration: 1.2), value: firstVisible)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        NeonScoresTitle(visible: titleVisible)

                        if vm.gameMode == .roles {
                            HStack {
                                Spacer()
                                Button { showRolesLegend = true } label: {
                                    Image(systemName: "info.circle")
                                        .font(.title3)
                                        .foregroundStyle(Color.appGrey)
                                        .frame(width: 44, height: 44)
                                }
                                .accessibilityLabel("Les rôles")
                                .opacity(titleVisible ? 1 : 0)
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.top, 44)
                    .padding(.bottom, 28)

                    // Podium
                    CeremonyPodium(
                        groups: podiumGroups,
                        thirdVisible: thirdVisible,
                        secondVisible: secondVisible,
                        firstVisible: firstVisible,
                        onTap: { group in selectedGroup = group },
                        onLongPressFirst: {
                            burstID = UUID()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                    )
                    .padding(.horizontal, 16)

                    // 4th place and below
                    if !rest.isEmpty {
                        VStack(spacing: 6) {
                            ForEach(Array(rest.enumerated()), id: \.element.id) { idx, player in
                                let rank = restStartRank + idx
                                HStack(spacing: 8) {
                                    Text("\(rank)")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color.appGrey)
                                        .frame(width: 22, alignment: .leading)
                                    Text(player.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.playerColor(player.colorIndex))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Spacer()
                                    Text("\(player.score) pts")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.appGrey)
                                    Text("détails")
                                        .font(.caption2)
                                        .foregroundStyle(Color.appGrey.opacity(0.5))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.appSurface.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal, 20)

                                .accessibilityAddTraits(.isButton)
                                .accessibilityLabel("\(player.name), \(player.score) points, classé \(rank). Appuyer pour détails.")
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    selectedGroup = PodiumGroup(rank: rank, players: [player], score: player.score)
                                }
                            }
                        }
                        .padding(.top, 20)
                        .opacity(firstVisible ? 1 : 0)
                        .offset(y: firstVisible ? 0 : 16)
                        .animation(.easeOut(duration: 0.4).delay(0.2), value: firstVisible)
                    }

                    // Titres de fin de partie
                    if hasEndGameBonuses {
                        EndGameBonusSection(
                            invincibilityWinners: invincibilityWinners,
                            topDetectiveWinners: topDetectiveWinners,
                            stalkerWinners: stalkerWinners,
                            visible: bonusVisible
                        )
                        .padding(.top, 28)
                    }

                    // Rôles (circonstances aggravantes)
                    if hasRoleBonuses {
                        CirconstancesSection(displayedBonuses: displayedBonuses, visible: bonusVisible)
                            .padding(.top, hasEndGameBonuses ? 16 : 28)
                    }

                    // CTA
                    VStack(spacing: 12) {
                        PrimaryButton(title: "Rejouer", color: vm.themeColor, textColor: .appBackground) {
                            vm.resetGame(keepPlayers: true)
                        }
                        Button("Accueil") {
                            vm.resetGame(keepPlayers: false)
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.appGrey)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 44)
                    .opacity(bonusVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.1), value: bonusVisible)
                }
            }

            // Confetti
            if confettiVisible {
                ConfettiView(winnerColor: firstPlaceColor)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            if let bid = burstID {
                ConfettiView(winnerColor: firstPlaceColor)
                    .id(bid)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .sheet(item: $selectedGroup) { group in
            PlayerDetailSheet(
                group: group,
                rounds: vm.rounds,
                allPlayers: vm.players,
                roleBonuses: vm.roleBonusResults,
                ranking: vm.finalRanking
            )
            .presentationDetents([.medium, .large])
            .presentationBackground(Color.appBlack)
        }
        .sheet(isPresented: $showRolesLegend) { RolesLegendeView() }
        .onAppear { runCeremony() }
    }

    // MARK: Ceremony

    private func runCeremony() {
        if reduceMotion {
            titleVisible = true; thirdVisible = true; secondVisible = true
            firstVisible = true; bonusVisible = true; confettiVisible = true
            return
        }
        withAnimation(.easeOut(duration: 0.6)) { titleVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { thirdVisible = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { secondVisible = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) { firstVisible = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            confettiVisible = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation(.easeOut(duration: 0.5)) { bonusVisible = true }
        }
    }
}

// MARK: - NeonScoresTitle

private struct NeonScoresTitle: View {
    let visible: Bool
    @State private var kerning: CGFloat = 8

    var body: some View {
        Text("SCORES")
            .font(.system(size: 32, weight: .black))
            .kerning(kerning)
            .foregroundStyle(Color.appWhite)
            .shadow(color: Color.appAccent.opacity(0.55), radius: 8)
            .shadow(color: Color.appAccent.opacity(0.25), radius: 22)
            .opacity(visible ? 1 : 0)
            .onChange(of: visible) { _, newVal in
                guard newVal else { return }
                withAnimation(.easeOut(duration: 0.9)) { kerning = 2 }
            }
    }
}

// MARK: - CeremonyPodium

private struct CeremonyPodium: View {
    let groups: [PodiumGroup]
    let thirdVisible: Bool
    let secondVisible: Bool
    let firstVisible: Bool
    let onTap: (PodiumGroup) -> Void
    let onLongPressFirst: () -> Void

    private struct DisplayItem: Identifiable {
        let id: UUID
        let group: PodiumGroup
        let visible: Bool
    }

    private var displayItems: [DisplayItem] {
        var result: [DisplayItem] = []
        if groups.count >= 2 { result.append(DisplayItem(id: groups[1].id, group: groups[1], visible: secondVisible)) }
        if groups.count >= 1 { result.append(DisplayItem(id: groups[0].id, group: groups[0], visible: firstVisible)) }
        if groups.count >= 3 { result.append(DisplayItem(id: groups[2].id, group: groups[2], visible: thirdVisible)) }
        return result
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(displayItems) { item in
                PodiumCard(
                    group: item.group,
                    visible: item.visible,
                    onTap: { onTap(item.group) },
                    onLongPress: item.group.rank == 1 ? onLongPressFirst : nil
                )
            }
        }
    }
}

// MARK: - PodiumCard

private struct PodiumCard: View {
    let group: PodiumGroup
    let visible: Bool
    let onTap: () -> Void
    let onLongPress: (() -> Void)?

    @State private var pulseOpacity: Double = 0.3
    @State private var trophyOffset: CGFloat = 0
    @State private var pressScale: CGFloat = 1.0

    private var isFirst: Bool { group.rank == 1 }

    private var cardColor: Color {
        switch group.rank {
        case 1:  return Color(hex: "#EDD88A")
        case 2:  return Color(hex: "#C4C8D4")
        default: return Color(hex: "#D4A870")
        }
    }

    private var medal: String {
        switch group.rank {
        case 1:  return "🏆"
        case 2:  return "🥈"
        default: return "🥉"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Names above card
            VStack(spacing: 3) {
                ForEach(group.players) { player in
                    Text(player.name)
                        .font(isFirst ? .title3.weight(.black) : .subheadline.weight(.bold))
                        .foregroundStyle(Color.playerColor(player.colorIndex))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                Text(medal)
                    .font(.system(size: isFirst ? 42 : 26))
                    .offset(y: trophyOffset)
            }
            .padding(.bottom, isFirst ? 10 : 6)

            // Score card
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(cardColor.opacity(isFirst ? 0.16 : 0.10))

                if isFirst {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(cardColor.opacity(pulseOpacity), lineWidth: 2)
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(cardColor.opacity(0.45), lineWidth: 1.5)
                }

                VStack(spacing: 2) {
                    Text("\(group.score)")
                        .font(isFirst ? .title.weight(.black) : .title3.weight(.black))
                        .foregroundStyle(cardColor)
                    Text("pts")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(cardColor.opacity(0.7))
                    Text("détails")
                        .font(.caption2)
                        .foregroundStyle(Color.appGrey.opacity(0.45))
                        .padding(.top, 4)
                        .opacity(visible ? 1 : 0)
                }
            }
            .frame(height: isFirst ? 150 : 100)
            .shadow(color: isFirst ? cardColor.opacity(0.22) : .clear, radius: 18, y: 4)
        }
        .scaleEffect(pressScale)
        .scaleEffect(visible ? 1 : (isFirst ? 0.6 : 0.5))
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : 40)
        .frame(maxWidth: .infinity)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("\(group.players.map(\.name).joined(separator: ", ")), \(group.score) points, \(group.rank == 1 ? "1er" : "\(group.rank)ème"). Appuyer pour détails.")
        .onTapGesture {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) { pressScale = 0.93 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { pressScale = 1.0 }
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            onLongPress?()
        }
        .onAppear {
            guard visible else { return }
            startAnimations()
        }
        .onChange(of: visible) { _, newVal in
            guard newVal else { return }
            startAnimations()
        }
    }

    private var bobOffset: CGFloat {
        switch group.rank {
        case 1:  return -6
        case 2:  return -4
        default: return -3
        }
    }

    private var bobDuration: Double {
        switch group.rank {
        case 1:  return 1.4
        case 2:  return 1.7
        default: return 2.0
        }
    }

    private func startAnimations() {
        let delay = isFirst ? 0.4 : 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if isFirst {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseOpacity = 1.0
                }
            }
            withAnimation(.easeInOut(duration: bobDuration).repeatForever(autoreverses: true)) {
                trophyOffset = bobOffset
            }
        }
    }
}

// MARK: - PlayerDetailSheet

private struct PlayerDetailSheet: View {
    let group: PodiumGroup
    let rounds: [GameRound]
    let allPlayers: [Player]
    let roleBonuses: [GameViewModel.RoleBonus]
    let ranking: [Player]

    private func tiebreakerNote(for playerID: UUID) -> String? {
        guard let idx = ranking.firstIndex(where: { $0.id == playerID }) else { return nil }
        let score = ranking[idx].score
        var neighbors: [String] = []
        if idx > 0 && ranking[idx - 1].score == score { neighbors.append(ranking[idx - 1].name) }
        if idx + 1 < ranking.count && ranking[idx + 1].score == score { neighbors.append(ranking[idx + 1].name) }
        guard !neighbors.isEmpty else { return nil }
        return "Même score que \(neighbors.joined(separator: " & ")). Classé par départage : honte suprême · insaisissable · fin limier · oreille absolue."
    }

    private func badgeCounts(for playerID: UUID) -> (oreille: Int, finLimier: Int, insaisissable: Int, honteSupreme: Int) {
        var oreille = 0, finLimier = 0, insaisissable = 0, honteSupreme = 0
        let otherCount = allPlayers.filter { $0.id != playerID }.count

        for round in rounds {
            let ownerID = round.track.ownerID
            let correctVoters = round.votes.filter { $0.key != ownerID && $0.value == ownerID }

            if ownerID != playerID, round.votes[playerID] == ownerID {
                oreille += 1
                if correctVoters.count == 1 { finLimier += 1 }
            }
            if ownerID == playerID {
                if correctVoters.isEmpty { insaisissable += 1 }
                if correctVoters.count == otherCount { honteSupreme += 1 }
            }
        }
        return (oreille, finLimier, insaisissable, honteSupreme)
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.appGrey.opacity(0.4))
                .frame(width: 36, height: 4)
                .padding(.top, 16)
                .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(group.players) { player in
                        let b = badgeCounts(for: player.id)
                        let roleBonus = roleBonuses.first { $0.player.id == player.id }
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.playerColor(player.colorIndex))
                                    .frame(width: 12, height: 12)
                                Text(player.name)
                                    .font(.title3.weight(.black))
                                    .foregroundStyle(Color.playerColor(player.colorIndex))
                                Spacer()
                                Text("\(group.score) pts · #\(group.rank)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.appGrey)
                            }

                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 8
                            ) {
                                BadgeDetailCell(emoji: "👂", title: "OREILLE ABSOLUE",
                                                count: b.oreille, color: Color.appAccent)
                                BadgeDetailCell(emoji: "🕯️", title: "FIN LIMIER",
                                                count: b.finLimier, color: Color(hex: "#F4C542"))
                                BadgeDetailCell(emoji: "✨", title: "INSAISISSABLE",
                                                count: b.insaisissable, color: Color.appAccent)
                                BadgeDetailCell(emoji: "☠️", title: "HONTE SUPRÊME",
                                                count: b.honteSupreme, color: Color.appGrey)
                            }

                            if let bonus = roleBonus {
                                RoleBonusDetailRow(bonus: bonus)
                            }

                            if let note = tiebreakerNote(for: player.id) {
                                HStack(alignment: .top, spacing: 6) {
                                    Image(systemName: "info.circle")
                                        .font(.caption)
                                        .foregroundStyle(Color.appGrey)
                                    Text(note)
                                        .font(.caption)
                                        .foregroundStyle(Color.appGrey)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(10)
                                .background(Color.appGrey.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(16)
                        .background(Color.appSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

private struct RoleBonusDetailRow: View {
    let bonus: GameViewModel.RoleBonus

    var body: some View {
        HStack(spacing: 10) {
            Text(bonus.role.emoji)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(bonus.role.title.uppercased())
                    .font(.caption2.weight(.black))
                    .kerning(0.8)
                    .foregroundStyle(bonus.role.accentColor)
                Text(bonus.succeeded ? bonus.label : "Mission échouée")
                    .font(.caption)
                    .foregroundStyle(bonus.succeeded ? Color.appGreyLight : Color.appGrey)
            }
            Spacer()
            if bonus.succeeded && bonus.points > 0 {
                Text("+\(bonus.points) pts")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Color.scoreBonus)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.scoreBonus.opacity(0.12))
                    .clipShape(Capsule())
            } else if !bonus.succeeded {
                Text("❌")
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(bonus.role.accentColor.opacity(bonus.succeeded ? 0.1 : 0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct BadgeDetailCell: View {
    let emoji: String
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(emoji)
                .font(.title3)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2.weight(.black))
                    .kerning(0.8)
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                Text(count > 0 ? "\(count)×" : "—")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(count > 0 ? Color.appWhite : Color.appGrey)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(color.opacity(count > 0 ? 0.12 : 0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - EndGameBonusSection

private struct EndGameBonusSection: View {
    let invincibilityWinners: [Player]
    let topDetectiveWinners: [Player]
    let stalkerWinners: [Player]
    let visible: Bool

    var body: some View {
        VStack(spacing: 8) {
            SectionDividerLabel(title: "TITRES DE FIN DE PARTIE", color: Color.appPremiumGold)
                .padding(.horizontal, 20)

            ForEach(invincibilityWinners) { player in
                BonusRow(colorIndex: player.colorIndex, name: player.name,
                         label: "🔪 \(BadgeTitles.crimePerfait.uppercased())",
                         labelColor: Color.appGreyLight,
                         points: ScoringConfig.invincibilityBonus, failed: false)
            }
            ForEach(topDetectiveWinners) { player in
                BonusRow(colorIndex: player.colorIndex, name: player.name,
                         label: "🔍 \(BadgeTitles.inspecteurImplacable.uppercased())",
                         labelColor: Color.appGreyLight,
                         points: ScoringConfig.topDetectiveBonus, failed: false)
            }
            ForEach(stalkerWinners) { player in
                BonusRow(colorIndex: player.colorIndex, name: player.name,
                         label: "💯 \(BadgeTitles.temoinGenant.uppercased())",
                         labelColor: Color.appGreyLight,
                         points: ScoringConfig.stalkerBonus, failed: false)
            }
        }
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : 20)
    }
}

// MARK: - CirconstancesSection (rôles secrets)

private struct CirconstancesSection: View {
    let displayedBonuses: [GameViewModel.RoleBonus]
    let visible: Bool

    var body: some View {
        VStack(spacing: 8) {
            SectionDividerLabel(title: "RÔLES SECRETS", color: Color.appPremiumGold)
                .padding(.horizontal, 20)

            ForEach(Array(displayedBonuses.enumerated()), id: \.offset) { _, bonus in
                BonusRow(
                    colorIndex: bonus.player.colorIndex,
                    name: bonus.player.name,
                    label: "\(bonus.role.emoji) \(bonus.role.title.uppercased())",
                    labelColor: bonus.succeeded ? bonus.role.accentColor : Color.appGrey,
                    points: bonus.succeeded && bonus.points > 0 ? bonus.points : nil,
                    failed: !bonus.succeeded
                )
            }
        }
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : 20)
    }
}

// MARK: - BonusRow

private struct BonusRow: View {
    let colorIndex: Int
    let name: String
    let label: String
    let labelColor: Color
    var points: Int? = nil
    var failed: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.playerColor(colorIndex))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(labelColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            if failed {
                Text("❌")
                    .font(.subheadline)
            } else if let pts = points, pts > 0 {
                Text("+\(pts) pts")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Color.scoreBonus)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.scoreBonus.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.appGreyLight.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 20)
    }
}

// MARK: - ConfettiView

private struct ConfettiView: UIViewRepresentable {
    var winnerColor: Color = .white

    func makeUIView(context: Context) -> ConfettiEmitterView {
        let view = ConfettiEmitterView(winnerColor: UIColor(winnerColor))
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: ConfettiEmitterView, context: Context) {}
}

final class ConfettiEmitterView: UIView {
    private var emitterSetUp = false
    private let emitter = CAEmitterLayer()
    private let winnerColor: UIColor

    init(winnerColor: UIColor) {
        self.winnerColor = winnerColor
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !emitterSetUp, bounds.width > 0 else { return }
        emitterSetUp = true
        setupEmitter()
    }

    private func makeCell(color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 7
        cell.lifetime = 5.5
        cell.lifetimeRange = 1.5
        cell.velocity = 330
        cell.velocityRange = 130
        cell.emissionRange = .pi / 4
        cell.emissionLongitude = .pi / 2
        cell.spin = 4
        cell.spinRange = 3
        cell.scale = 0.22
        cell.scaleRange = 0.12
        cell.yAcceleration = 135
        cell.color = color.withAlphaComponent(0.9).cgColor
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 14, height: 9))
        let img = renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 14, height: 9))
        }
        cell.contents = img.cgImage
        return cell
    }

    private func setupEmitter() {
        emitter.emitterPosition = CGPoint(x: bounds.width / 2, y: -10)
        emitter.emitterSize   = CGSize(width: bounds.width, height: 1)
        emitter.emitterShape  = .line
        emitter.renderMode    = .oldestFirst

        let extras: [UIColor] = [
            UIColor(red: 1.00, green: 0.85, blue: 0.24, alpha: 1),
            UIColor(red: 0.42, green: 0.80, blue: 0.47, alpha: 1),
            UIColor(red: 0.66, green: 0.33, blue: 0.97, alpha: 1),
            UIColor(red: 0.96, green: 0.45, blue: 0.71, alpha: 1),
            UIColor(red: 1.00, green: 0.56, blue: 0.10, alpha: 1),
        ]
        emitter.emitterCells = ([winnerColor, winnerColor] + extras).map { makeCell(color: $0) }
        layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.emitter.birthRate = 0
        }
    }
}
