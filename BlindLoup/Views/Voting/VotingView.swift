import SwiftUI

struct VotingView: View {
    @Environment(GameViewModel.self) private var vm
    let roundIndex: Int

    @State private var currentVoterIndex: Int = 0
    @State private var voterReady: Bool = false
    @State private var pendingVote: UUID? = nil
    @State private var showConfirmation = false

    var round: GameRound? {
        vm.rounds.indices.contains(roundIndex) ? vm.rounds[roundIndex] : nil
    }

    var allVoters: [Player] { vm.players }

    var currentVoter: Player? {
        allVoters.indices.contains(currentVoterIndex) ? allVoters[currentVoterIndex] : nil
    }

    var allVoted: Bool {
        vm.allPlayersVoted(roundIndex: roundIndex)
    }

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            if let voter = currentVoter {
                if !voterReady {
                    ProtectionScreen(message: "Passez le téléphone à \(voter.name)") {
                        voterReady = true
                    }
                } else if vm.hasVoted(voter.id, roundIndex: roundIndex) {
                    votedConfirmation(for: voter)
                } else {
                    votingContent(for: voter)
                }
            } else if allVoted {
                Color.appBlack.ignoresSafeArea()
                    .onAppear { vm.advancePhase() }
            }
        }
        .alert("Confirmer ton vote ?", isPresented: $showConfirmation) {
            Button("Confirmer") {
                if let voter = currentVoter, let votedID = pendingVote {
                    vm.submitVote(voterID: voter.id, votedPlayerID: votedID, roundIndex: roundIndex)
                    advanceVoter()
                }
            }
            Button("Annuler", role: .cancel) { pendingVote = nil }
        } message: {
            if let name = allVoters.first(where: { $0.id == pendingVote })?.name {
                Text("Tu votes pour \(name) ?")
            }
        }
    }

    @ViewBuilder
    private func votingContent(for voter: Player) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("À qui appartient ce morceau ?")
                    .font(.headline)
                    .foregroundStyle(Color.appWhite)
                Text("\(voter.name), c'est ton tour")
                    .font(.subheadline)
                    .foregroundStyle(Color.appGrey)
            }
            .padding(.top, 60)
            .padding(.bottom, 24)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(allVoters.filter { $0.id != voter.id }) { player in
                        let pColor = Color.playerColor(player.colorIndex)
                        Button(action: {
                            pendingVote = player.id
                            showConfirmation = true
                        }) {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(pColor)
                                    .frame(width: 14, height: 14)
                                Text(player.name)
                                    .font(.headline)
                                    .foregroundStyle(Color.appWhite)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.appGrey)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(pColor.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(pColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.appBlack)
    }

    @ViewBuilder
    private func votedConfirmation(for voter: Player) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.appOrange)
            Text("\(voter.name) a voté !")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.appWhite)
            Text("Passez le téléphone au prochain joueur")
                .font(.subheadline)
                .foregroundStyle(Color.appGrey)
        }
    }

    private func advanceVoter() {
        let nextIndex = currentVoterIndex + 1
        if nextIndex < allVoters.count {
            currentVoterIndex = nextIndex
            voterReady = false
        } else {
            vm.advancePhase()
        }
    }
}
