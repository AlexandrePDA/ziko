import SwiftUI

struct SecretSelectionView: View {
    @Environment(GameViewModel.self) private var vm
    let playerIndex: Int
    @State private var showSearch = false

    var player: Player? {
        vm.players.indices.contains(playerIndex) ? vm.players[playerIndex] : nil
    }

    var tracksLimit: Int { vm.tracksPerPlayer }

    var canContinue: Bool {
        (player?.selectedTracks.count ?? 0) == tracksLimit
    }

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            if let player {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Sélection secrète")
                            .font(.caption)
                            .foregroundStyle(Color.appGrey)
                            .textCase(.uppercase)
                        Text(player.name)
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundStyle(Color.playerColor(player.colorIndex))
                        Text("\(player.selectedTracks.count)/\(tracksLimit) morceaux")
                            .font(.subheadline)
                            .foregroundStyle(Color.appGrey)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                    // Selected tracks
                    ScrollView {
                        VStack(spacing: 8) {
                            if player.selectedTracks.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "music.note.list")
                                        .font(.system(size: 48))
                                        .foregroundStyle(Color.appNavy)
                                    Text("Ajoute exactement \(tracksLimit) morceau\(tracksLimit > 1 ? "x" : "")\npour bluffer tes amis !")
                                        .font(.body)
                                        .foregroundStyle(Color.appGrey)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 40)
                            } else {
                                ForEach(player.selectedTracks) { track in
                                    HStack(spacing: 0) {
                                        TrackRowView(track: track, isSelected: false)
                                        Button(action: {
                                            vm.removeTrack(track, from: player.id)
                                        }) {
                                            Image(systemName: "trash")
                                                .font(.body)
                                                .foregroundStyle(Color.appOrange)
                                                .padding(.horizontal, 16)
                                                .frame(maxHeight: .infinity)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .background(Color.appNavy)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    }

                    // Actions
                    VStack(spacing: 12) {
                        Button(action: { showSearch = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Ajouter un morceau (\(player.selectedTracks.count)/\(tracksLimit))")
                            }
                            .font(.headline)
                            .foregroundStyle(Color.appOrange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.appOrange, lineWidth: 1.5)
                            )
                        }
                        .disabled(player.selectedTracks.count >= tracksLimit)
                        .opacity(player.selectedTracks.count >= tracksLimit ? 0.4 : 1)

                        PrimaryButton(
                            title: playerIndex == vm.players.count - 1 ? "Lancer le jeu" : "Suivant",
                            isDisabled: !canContinue
                        ) {
                            vm.advancePhase()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.appBlack)
                }
            }
        }
        .sheet(isPresented: $showSearch) {
            if let player {
                TrackSearchView(playerID: player.id)
            }
        }
    }
}
