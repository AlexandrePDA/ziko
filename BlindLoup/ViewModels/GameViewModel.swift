import Foundation
import Observation
import SwiftUI

// MARK: - GameMode

enum GameMode: Equatable {
    case classic
    case roles
}

@Observable
final class GameViewModel {

    // MARK: - State

    var phase: GamePhase = .home
    var players: [Player] = []
    var rounds: [GameRound] = []
    var tracksPerPlayer: Int = GameConfig.freeTracksPerPlayer
    var gameMode: GameMode = .classic

    // MARK: - Roles state

    /// playerID → assigned role (populated when the roles game starts)
    var playerRoles: [UUID: RoleType] = [:]

    /// obsessionnelPlayerID → chosen suspectID
    var obsessionnelSuspects: [UUID: UUID] = [:]

    /// Provocateur players who have already used their doubling
    var provocateurDoublingUsed: Set<UUID> = []

    /// If set, the next vote submitted by this player will be doubled (Provocateur power)
    var provocateurPendingDoubling: UUID? = nil

    // MARK: - Dependencies

    let storeService: StoreKitService
    let historyService: GameHistoryService

    init(storeService: StoreKitService = StoreKitService(),
         historyService: GameHistoryService = .shared) {
        self.storeService = storeService
        self.historyService = historyService
    }

    // MARK: - Computed

    var currentRound: GameRound? {
        guard case .blindTest(let idx) = phase, rounds.indices.contains(idx) else { return nil }
        return rounds[idx]
    }

    var finalRanking: [Player] {
        players.sorted {
            if $0.score != $1.score { return $0.score > $1.score }
            return tiebreakScore(for: $0) > tiebreakScore(for: $1)
        }
    }

    var invincibilityWinners: [Player] {
        players.filter { player in
            let ownedRounds = rounds.filter { $0.track.ownerID == player.id }
            guard !ownedRounds.isEmpty else { return false }
            return !ownedRounds.contains { round in
                round.votes.contains { $0.value == player.id && $0.key != player.id }
            }
        }
    }

    /// Accent color for buttons and UI elements throughout the game flow
    var themeColor: Color {
        gameMode == .roles ? Color.playerColor(1) : Color.appOrange
    }

    var maxPlayers: Int {
        storeService.isPremium ? 8 : GameConfig.freeMaxPlayers
    }

    var maxTracksPerPlayer: Int {
        storeService.isPremium ? GameConfig.premiumTracksOptions.last ?? 6 : GameConfig.freeTracksPerPlayer
    }

    // MARK: - Setup

    func addPlayer(name: String) {
        guard players.count < maxPlayers else { return }
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        players.append(Player(name: trimmed, colorIndex: players.count))
    }

    func removePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }

    func renamePlayer(id: UUID, newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        if let idx = players.firstIndex(where: { $0.id == id }) {
            players[idx].name = trimmed
        }
    }

    // MARK: - Track selection

    @discardableResult
    func addTrack(_ track: Track, to playerID: UUID) -> Bool {
        guard let idx = players.firstIndex(where: { $0.id == playerID }) else { return false }
        let limit = storeService.isPremium ? (GameConfig.premiumTracksOptions.last ?? 6) : GameConfig.freeTracksPerPlayer
        guard players[idx].selectedTracks.count < limit else { return false }
        guard !players[idx].selectedTracks.contains(where: { $0.id == track.id }) else { return false }
        var updated = track
        updated.ownerID = playerID
        players[idx].selectedTracks.append(updated)
        return true
    }

    func removeTrack(_ track: Track, from playerID: UUID) {
        guard let idx = players.firstIndex(where: { $0.id == playerID }) else { return }
        players[idx].selectedTracks.removeAll { $0.id == track.id }
    }

    func tracksForPlayer(_ playerID: UUID) -> [Track] {
        players.first(where: { $0.id == playerID })?.selectedTracks ?? []
    }

    // MARK: - Phase transitions

    func advancePhase() {
        switch phase {
        case .home:
            phase = .classicMenu

        case .classicMenu:
            players = []
            gameMode = .classic
            phase = .setup

        case .rolesMenu:
            players = []
            gameMode = .roles
            phase = .setup

        case .setup:
            guard players.count >= GameConfig.minPlayers else { return }
            if gameMode == .roles {
                assignRoles()
            }
            phase = .transition(nextPlayerIndex: 0)

        case .secretSelection(let idx):
            let next = idx + 1
            if next < players.count {
                phase = .transition(nextPlayerIndex: next)
            } else {
                buildRounds()
                phase = .blindTest(roundIndex: 0)
            }

        case .transition(let next):
            if gameMode == .roles {
                phase = .roleReveal(playerIndex: next)
            } else {
                phase = .secretSelection(playerIndex: next)
            }

        case .roleReveal(let idx):
            phase = .secretSelection(playerIndex: idx)

        case .blindTest(let idx):
            phase = .voting(roundIndex: idx)

        case .voting(let idx):
            phase = .reveal(roundIndex: idx)

        case .reveal(let idx):
            applyScores(roundIndex: idx)
            let next = idx + 1
            if next < rounds.count {
                phase = .blindTest(roundIndex: next)
            } else {
                applyPerfectBluffBonuses()
                if gameMode == .roles {
                    applyRoleBonuses()
                }
                saveHistory()
                phase = .finalResults
            }

        case .finalResults:
            phase = .home
        }
    }

    func startFirstPlayer() {
        if gameMode == .roles {
            assignRoles()
        }
        phase = .transition(nextPlayerIndex: 0)
    }

    func goToRolesMenu() {
        phase = .rolesMenu
    }

    // MARK: - Voting

    func submitVote(voterID: UUID, votedPlayerID: UUID, roundIndex: Int) {
        guard rounds.indices.contains(roundIndex) else { return }
        guard rounds[roundIndex].votes[voterID] == nil else { return }

        // Commit any pending Provocateur doubling
        if provocateurPendingDoubling == voterID {
            rounds[roundIndex].doublingVoters.insert(voterID)
            provocateurPendingDoubling = nil
            provocateurDoublingUsed.insert(voterID)
        }

        rounds[roundIndex].votes[voterID] = votedPlayerID
    }

    func hasVoted(_ voterID: UUID, roundIndex: Int) -> Bool {
        guard rounds.indices.contains(roundIndex) else { return false }
        return rounds[roundIndex].votes[voterID] != nil
    }

    func allPlayersVoted(roundIndex: Int) -> Bool {
        guard rounds.indices.contains(roundIndex) else { return false }
        return players.allSatisfy { rounds[roundIndex].votes[$0.id] != nil }
    }

    /// Activate Provocateur doubling for the current voter (if not already used)
    func activateProvocateurDoubling(for playerID: UUID) {
        guard !provocateurDoublingUsed.contains(playerID) else { return }
        provocateurPendingDoubling = (provocateurPendingDoubling == playerID) ? nil : playerID
    }

    func hasUsedDoubling(_ playerID: UUID) -> Bool {
        provocateurDoublingUsed.contains(playerID)
    }

    func isPendingDoubling(_ playerID: UUID) -> Bool {
        provocateurPendingDoubling == playerID
    }

    // MARK: - Role helpers

    func role(for playerID: UUID) -> RoleType? {
        playerRoles[playerID]
    }

    func suspect(for obsessionnelID: UUID) -> Player? {
        guard let suspectID = obsessionnelSuspects[obsessionnelID] else { return nil }
        return players.first { $0.id == suspectID }
    }

    func setSuspect(_ suspectID: UUID, for obsessionnelID: UUID) {
        obsessionnelSuspects[obsessionnelID] = suspectID
    }

    var complices: [Player] {
        players.filter { playerRoles[$0.id] == .complice }
    }

    // MARK: - Scoring

    func calculateRoundScore(round: GameRound) -> [UUID: Int] {
        var deltas: [UUID: Int] = [:]
        let ownerID = round.track.ownerID
        let correctVoters = round.votes.filter { $0.value == ownerID && $0.key != ownerID }.map { $0.key }
        let otherPlayersCount = players.count - 1

        // Base scoring (classic rules)
        if correctVoters.isEmpty {
            deltas[ownerID] = (deltas[ownerID] ?? 0) + ScoringConfig.bluffSuccessPoints
        } else if correctVoters.count == otherPlayersCount {
            deltas[ownerID] = (deltas[ownerID] ?? 0) - ScoringConfig.allFoundPenalty
            for voterID in correctVoters {
                deltas[voterID] = (deltas[voterID] ?? 0) + ScoringConfig.finderPoints
            }
        } else if correctVoters.count == 1 {
            deltas[correctVoters[0]] = (deltas[correctVoters[0]] ?? 0) + ScoringConfig.finderPoints + ScoringConfig.soleFinderBonus
        } else {
            for voterID in correctVoters {
                deltas[voterID] = (deltas[voterID] ?? 0) + ScoringConfig.finderPoints
            }
        }

        // Role modifiers (applied only in roles mode)
        if gameMode == .roles {
            applyRoleModifiers(to: &deltas, round: round, correctVoters: correctVoters)
        }

        return deltas
    }

    /// Applies per-round Sniper and Provocateur modifiers to score deltas.
    private func applyRoleModifiers(to deltas: inout [UUID: Int], round: GameRound, correctVoters: [UUID]) {
        let ownerID = round.track.ownerID
        let incorrectVoters = round.votes.filter { $0.value != ownerID && $0.key != ownerID }.map { $0.key }

        // Sniper: correct → ×2 finder points; wrong → −penalty
        for voterID in correctVoters where playerRoles[voterID] == .sniper {
            // They already received finderPoints (or soleBonus). Add finderPoints again to double.
            deltas[voterID] = (deltas[voterID] ?? 0) + ScoringConfig.finderPoints
        }
        for voterID in incorrectVoters where playerRoles[voterID] == .sniper {
            deltas[voterID] = (deltas[voterID] ?? 0) - ScoringConfig.sniperWrongPenalty
        }

        // Provocateur: doublingVoters get their result (correct or wrong) doubled
        for voterID in round.doublingVoters where playerRoles[voterID] == .provocateur {
            if correctVoters.contains(voterID) {
                // Double their finder points
                deltas[voterID] = (deltas[voterID] ?? 0) + ScoringConfig.finderPoints
            } else {
                // Double penalty for wrong vote
                deltas[voterID] = (deltas[voterID] ?? 0) - ScoringConfig.finderPoints * ScoringConfig.provocateurMultiplier
            }
        }
    }

    private func applyScores(roundIndex: Int) {
        guard rounds.indices.contains(roundIndex) else { return }
        rounds[roundIndex].isRevealed = true
        let deltas = calculateRoundScore(round: rounds[roundIndex])
        for (playerID, points) in deltas {
            if let idx = players.firstIndex(where: { $0.id == playerID }) {
                players[idx].score += points
            }
        }
    }

    // MARK: - Role bonus computation (end of game)

    private func applyRoleBonuses() {
        for player in players {
            guard let role = playerRoles[player.id] else { continue }
            switch role {
            case .doublure:
                if doublureSucceeded(player) { addScore(ScoringConfig.doublureBonus, to: player.id) }
            case .obsessionnel:
                if obsessionnelSucceeded(player) { addScore(ScoringConfig.obsessionnelBonus, to: player.id) }
            case .profiler:
                if profilerSucceeded(player) { addScore(ScoringConfig.profilerBonus, to: player.id) }
            case .innocent:
                if innocentSucceeded(player) { addScore(ScoringConfig.innocentBonus, to: player.id) }
            case .sniper, .provocateur, .complice, .melomane:
                break  // Sniper & Provocateur are handled per-round; Complice checked below; Mélomane has no bonus
            }
        }
        applyCompliceBonus()
    }

    /// 🎭 La Doublure: accused unanimously (all other players voted for them) while NOT being the owner, at least once.
    private func doublureSucceeded(_ player: Player) -> Bool {
        rounds.contains { round in
            guard round.track.ownerID != player.id else { return false }
            let otherVoters = players.filter { $0.id != player.id }
            return otherVoters.allSatisfy { round.votes[$0.id] == player.id }
        }
    }

    /// 🔎 L'Obsessionnel: voted for suspect on 3+ rounds AND suspect owns at least 1 track.
    private func obsessionnelSucceeded(_ player: Player) -> Bool {
        guard let suspectID = obsessionnelSuspects[player.id] else { return false }
        let timesAccused = rounds.filter { round in
            round.votes[player.id] == suspectID && round.track.ownerID != player.id
        }.count
        let suspectOwnsAtLeastOne = rounds.contains { $0.track.ownerID == suspectID }
        return timesAccused >= 3 && suspectOwnsAtLeastOne
    }

    /// 📋 Le Profiler: correctly identified tracks from 3 different players.
    private func profilerSucceeded(_ player: Player) -> Bool {
        let distinctOwners = Set(rounds.compactMap { round -> UUID? in
            guard round.track.ownerID != player.id else { return nil }
            return round.votes[player.id] == round.track.ownerID ? round.track.ownerID : nil
        })
        return distinctOwners.count >= 3
    }

    /// 😇 L'Innocent: accused (voted for) while NOT being the owner more than 3 times.
    private func innocentSucceeded(_ player: Player) -> Bool {
        let accusedCount = rounds.filter { round in
            guard round.track.ownerID != player.id else { return false }
            return round.votes.values.contains(player.id)
        }.count
        return accusedCount > 3
    }

    /// 🤝 Le Complice: both complices in top 3 → each gets the bonus.
    private func applyCompliceBonus() {
        let compliceIDs = playerRoles.filter { $0.value == .complice }.map { $0.key }
        guard compliceIDs.count == 2 else { return }
        let ranking = finalRanking
        let top3IDs = Set(ranking.prefix(3).map { $0.id })
        guard compliceIDs.allSatisfy({ top3IDs.contains($0) }) else { return }
        for id in compliceIDs { addScore(ScoringConfig.compliceBonus, to: id) }
    }

    private func addScore(_ points: Int, to playerID: UUID) {
        if let idx = players.firstIndex(where: { $0.id == playerID }) {
            players[idx].score += points
        }
    }

    // MARK: - Role bonus results (for FinalScoreView display)

    struct RoleBonus {
        let player: Player
        let role: RoleType
        let points: Int
        let label: String
        let succeeded: Bool
    }

    var roleBonusResults: [RoleBonus] {
        guard gameMode == .roles else { return [] }
        var results: [RoleBonus] = []

        for player in players {
            guard let role = playerRoles[player.id] else { continue }
            switch role {
            case .doublure:
                let ok = doublureSucceeded(player)
                results.append(RoleBonus(player: player, role: role,
                    points: ScoringConfig.doublureBonus,
                    label: "Accusé à l'unanimité à tort", succeeded: ok))
            case .obsessionnel:
                let ok = obsessionnelSucceeded(player)
                results.append(RoleBonus(player: player, role: role,
                    points: ScoringConfig.obsessionnelBonus,
                    label: "Mission Obsessionnel accomplie", succeeded: ok))
            case .profiler:
                let ok = profilerSucceeded(player)
                results.append(RoleBonus(player: player, role: role,
                    points: ScoringConfig.profilerBonus,
                    label: "3 joueurs profilés", succeeded: ok))
            case .innocent:
                let ok = innocentSucceeded(player)
                results.append(RoleBonus(player: player, role: role,
                    points: ScoringConfig.innocentBonus,
                    label: "Victime expiatoire", succeeded: ok))
            case .sniper:
                results.append(RoleBonus(player: player, role: role,
                    points: 0, label: "Points modifiés par manche", succeeded: true))
            case .provocateur:
                let used = provocateurDoublingUsed.contains(player.id)
                results.append(RoleBonus(player: player, role: role,
                    points: 0, label: used ? "Mise doublée utilisée" : "Mise doublée non utilisée", succeeded: used))
            case .complice, .melomane:
                break  // Complice shown separately; Mélomane has no bonus
            }
        }

        // Complice
        let compliceIDs = playerRoles.filter { $0.value == .complice }.map { $0.key }
        if compliceIDs.count == 2 {
            let top3IDs = Set(finalRanking.prefix(3).map { $0.id })
            let ok = compliceIDs.allSatisfy({ top3IDs.contains($0) })
            for id in compliceIDs {
                if let player = players.first(where: { $0.id == id }) {
                    results.append(RoleBonus(player: player, role: .complice,
                        points: ScoringConfig.compliceBonus,
                        label: "Alliance secrète dans le top 3", succeeded: ok))
                }
            }
        }

        return results
    }

    // MARK: - Helpers

    private func applyPerfectBluffBonuses() {
        for player in players {
            let ownedRounds = rounds.filter { $0.track.ownerID == player.id }
            guard !ownedRounds.isEmpty else { continue }
            let wasFoundAtLeastOnce = ownedRounds.contains { round in
                round.votes.contains { $0.value == player.id && $0.key != player.id }
            }
            if !wasFoundAtLeastOnce {
                if let idx = players.firstIndex(where: { $0.id == player.id }) {
                    players[idx].score += ScoringConfig.invincibilityBonus
                }
            }
        }
    }

    private func assignRoles() {
        playerRoles = RoleType.assign(to: players.map { $0.id })
        obsessionnelSuspects = [:]
        provocateurDoublingUsed = []
        provocateurPendingDoubling = nil
    }

    private func buildRounds() {
        let allTracks = players.flatMap { player in
            player.selectedTracks.map { track -> Track in
                var t = track
                t.ownerID = player.id
                return t
            }
        }
        rounds = allTracks.shuffled().map { GameRound(track: $0) }
    }

    /// Rounds where the player was neither the owner nor guessed by anyone — used as score tiebreaker.
    private func tiebreakScore(for player: Player) -> Int {
        rounds.filter { round in
            round.track.ownerID != player.id &&
            !round.votes.values.contains(player.id)
        }.count
    }

    private func saveHistory() {
        historyService.saveSession(players: players)
    }

    // MARK: - Reset

    func resetGame(keepPlayers: Bool = false) {
        rounds = []
        playerRoles = [:]
        obsessionnelSuspects = [:]
        provocateurDoublingUsed = []
        provocateurPendingDoubling = nil
        gameMode = .classic
        if keepPlayers {
            for idx in players.indices {
                players[idx].score = 0
                players[idx].selectedTracks = []
            }
            phase = .setup
        } else {
            players = []
            phase = .home
        }
    }
}
