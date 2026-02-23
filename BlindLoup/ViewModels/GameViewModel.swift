import Foundation
import Observation

@Observable
final class GameViewModel {

    // MARK: - State

    var phase: GamePhase = .home
    var players: [Player] = []
    var rounds: [GameRound] = []
    var tracksPerPlayer: Int = GameConfig.freeTracksPerPlayer

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
            return bluffCount(for: $0) > bluffCount(for: $1)
        }
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

    // MARK: - Track selection

    func addTrack(_ track: Track, to playerID: UUID) {
        guard let idx = players.firstIndex(where: { $0.id == playerID }) else { return }
        let limit = storeService.isPremium ? (GameConfig.premiumTracksOptions.last ?? 6) : GameConfig.freeTracksPerPlayer
        guard players[idx].selectedTracks.count < limit else { return }
        guard !players[idx].selectedTracks.contains(where: { $0.id == track.id }) else { return }
        var updated = track
        updated.ownerID = playerID
        players[idx].selectedTracks.append(updated)
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
            players = []
            phase = .setup

        case .setup:
            guard players.count >= GameConfig.minPlayers else { return }
            phase = .secretSelection(playerIndex: 0)

        case .secretSelection(let idx):
            let next = idx + 1
            if next < players.count {
                phase = .transition(nextPlayerIndex: next)
            } else {
                buildRounds()
                phase = .blindTest(roundIndex: 0)
            }

        case .transition(let next):
            phase = .secretSelection(playerIndex: next)

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
                saveHistory()
                phase = .finalResults
            }

        case .finalResults:
            phase = .home
        }
    }

    func startFirstPlayer() {
        phase = .transition(nextPlayerIndex: 0)
    }

    // MARK: - Voting

    func submitVote(voterID: UUID, votedPlayerID: UUID, roundIndex: Int) {
        guard rounds.indices.contains(roundIndex) else { return }
        guard rounds[roundIndex].votes[voterID] == nil else { return }
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

    // MARK: - Scoring

    func calculateRoundScore(round: GameRound) -> [UUID: Int] {
        var deltas: [UUID: Int] = [:]
        let ownerID = round.track.ownerID
        // Voters who found the owner, excluding the owner voting for themselves
        let correctVoters = round.votes.filter { $0.value == ownerID && $0.key != ownerID }.map { $0.key }
        let otherPlayersCount = players.count - 1  // players who can actually find the owner

        if correctVoters.isEmpty {
            // Nobody found the owner → owner gets +30
            deltas[ownerID] = (deltas[ownerID] ?? 0) + ScoringConfig.bluffSuccessPoints
        } else if correctVoters.count == otherPlayersCount {
            // Everyone found the owner → owner gets -10
            deltas[ownerID] = (deltas[ownerID] ?? 0) - ScoringConfig.allFoundPenalty
            for voterID in correctVoters {
                deltas[voterID] = (deltas[voterID] ?? 0) + ScoringConfig.finderPoints
            }
        } else if correctVoters.count == 1 {
            // Only one person found the owner → they get +10 +20 = +30 total
            deltas[correctVoters[0]] = (deltas[correctVoters[0]] ?? 0) + ScoringConfig.finderPoints + ScoringConfig.soleFinderBonus
        } else {
            // Multiple (but not all) found the owner → each gets +10
            for voterID in correctVoters {
                deltas[voterID] = (deltas[voterID] ?? 0) + ScoringConfig.finderPoints
            }
        }
        return deltas
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

    private func bluffCount(for player: Player) -> Int {
        rounds.filter { round in
            round.track.ownerID != player.id &&
            round.votes.values.contains(player.id) == false
        }.count
    }

    private func saveHistory() {
        historyService.saveSession(players: players)
    }

    // MARK: - Reset

    func resetGame(keepPlayers: Bool = false) {
        rounds = []
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
