import SwiftUI

struct VotingView: View {
    @Environment(GameViewModel.self) private var vm
    let roundIndex: Int

    @State private var currentVoterIndex: Int = 0
    @State private var voterReady: Bool = false
    @State private var pendingVote: UUID? = nil

    var currentVoter: Player? {
        vm.players.indices.contains(currentVoterIndex) ? vm.players[currentVoterIndex] : nil
    }

    var nextVoter: Player? {
        let next = currentVoterIndex + 1
        return vm.players.indices.contains(next) ? vm.players[next] : nil
    }

    var isLastVoter: Bool { currentVoterIndex == vm.players.count - 1 }

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            if let voter = currentVoter {
                // ProtectionScreen uniquement pour le premier votant
                if currentVoterIndex == 0 && !voterReady {
                    ProtectionScreen(message:
                        Text("Passez le téléphone à ").foregroundStyle(Color.appWhite)
                        + Text(voter.name).foregroundStyle(Color.playerColor(voter.colorIndex))
                    ) {
                        voterReady = true
                    }
                } else if vm.hasVoted(voter.id, roundIndex: roundIndex) {
                    votedConfirmation(for: voter)
                } else {
                    votingContent(for: voter)
                }
            } else {
                Color.appBlack.ignoresSafeArea()
                    .onAppear { vm.advancePhase() }
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
                    ForEach(vm.players.filter { $0.id != voter.id }) { player in
                        let pColor = Color.playerColor(player.colorIndex)
                        let isSelected = pendingVote == player.id
                        Button(action: { pendingVote = player.id }) {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(pColor)
                                    .frame(width: 14, height: 14)
                                Text(player.name)
                                    .font(.headline)
                                    .foregroundStyle(Color.appWhite)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(pColor)
                                        .font(.title3)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(Color.appGrey.opacity(0.4))
                                        .font(.title3)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(isSelected ? pColor.opacity(0.22) : pColor.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        isSelected ? pColor.opacity(0.7) : pColor.opacity(0.2),
                                        lineWidth: isSelected ? 1.5 : 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut(duration: 0.15), value: isSelected)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }

            Button(action: {
                guard let voter = currentVoter, let votedID = pendingVote else { return }
                vm.submitVote(voterID: voter.id, votedPlayerID: votedID, roundIndex: roundIndex)
                pendingVote = nil
            }) {
                Text("Voter")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(pendingVote == nil ? Color.appGrey : Color.appBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(pendingVote == nil ? Color.appSurface : Color.appAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(pendingVote == nil)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
            .animation(.easeInOut(duration: 0.2), value: pendingVote == nil)
        }
        .background(Color.appBlack)
    }

    @ViewBuilder
    private func votedConfirmation(for voter: Player) -> some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.appAccent)
                    .padding(.bottom, 12)

                (Text(voter.name)
                    .foregroundStyle(Color.playerColor(voter.colorIndex))
                 + Text(" a voté !")
                    .foregroundStyle(Color.appWhite))
                .font(.title2.weight(.black))
                .multilineTextAlignment(.center)

                if let next = nextVoter {
                    Spacer().frame(height: 12)

                    Text("Au tour de")
                        .font(.subheadline)
                        .foregroundStyle(Color.appGrey)

                    Text(next.name)
                        .font(.system(size: 40, weight: .black))
                        .foregroundStyle(Color.playerColor(next.colorIndex))
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .multilineTextAlignment(.center)

            Spacer()

            PrimaryButton(title: isLastVoter ? "Voir la révélation" : "C'est parti \(nextVoter?.name ?? "") !") {
                advanceVoter()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }

    private func advanceVoter() {
        let nextIndex = currentVoterIndex + 1
        if nextIndex < vm.players.count {
            currentVoterIndex = nextIndex
            voterReady = true  // on passe directement au vote, pas de ProtectionScreen
        } else {
            vm.advancePhase()
        }
    }
}
