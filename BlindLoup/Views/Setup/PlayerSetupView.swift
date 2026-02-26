import SwiftUI

struct PlayerSetupView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var newName = ""
    @State private var showMaxAlert = false
    @State private var editingPlayer: Player? = nil
    @State private var editedName = ""
    @State private var showEditAlert = false
    @FocusState private var fieldFocused: Bool

    var canStart: Bool {
        vm.players.count >= GameConfig.minPlayers
    }

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { vm.phase = .classicMenu }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundStyle(Color.appWhite)
                    }
                    Spacer()
                    Text("Joueurs")
                        .font(.headline)
                        .foregroundStyle(Color.appWhite)
                    Spacer()
                    Text("\(vm.players.count)/\(vm.maxPlayers)")
                        .font(.subheadline)
                        .foregroundStyle(Color.appGrey)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Player list
                List {
                    ForEach(vm.players) { player in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.playerColor(player.colorIndex))
                                .frame(width: 12, height: 12)
                            Text(player.name)
                                .foregroundStyle(Color.appWhite)
                            Spacer()
                        }
                        .listRowBackground(Color.appNavy)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                if let idx = vm.players.firstIndex(where: { $0.id == player.id }) {
                                    vm.removePlayer(at: IndexSet(integer: idx))
                                }
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                editingPlayer = player
                                editedName = player.name
                                showEditAlert = true
                            } label: {
                                Label("Modifier", systemImage: "pencil")
                            }
                            .tint(Color.appOrange)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                // Tracks per player (premium only, freemium fixed at 3)
                if vm.storeService.isPremium {
                    VStack(spacing: 8) {
                        Text("Morceaux par joueur")
                            .font(.caption)
                            .foregroundStyle(Color.appGrey)
                            .textCase(.uppercase)
                        HStack(spacing: 10) {
                            ForEach(GameConfig.premiumTracksOptions, id: \.self) { n in
                                Button(action: { vm.tracksPerPlayer = n }) {
                                    Text("\(n)")
                                        .font(.headline)
                                        .foregroundStyle(vm.tracksPerPlayer == n ? Color.appBlack : Color.appWhite)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(vm.tracksPerPlayer == n ? Color.appOrange : Color.appNavy)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                } else {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundStyle(Color.appOrange)
                        Text("\(GameConfig.freeTracksPerPlayer) morceaux par joueur")
                            .font(.caption)
                            .foregroundStyle(Color.appGrey)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }

                // Add player
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        TextField("Prénom du joueur", text: $newName)
                            .focused($fieldFocused)
                            .padding(12)
                            .background(Color.appNavy)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color.appWhite)
                            .tint(Color.appOrange)
                            .submitLabel(.done)
                            .onSubmit { addPlayer() }

                        Button(action: addPlayer) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    vm.players.count >= vm.maxPlayers ? Color.appGrey : Color.appOrange
                                )
                        }
                    }

                    PrimaryButton(title: "Commencer", isDisabled: !canStart) {
                        vm.startFirstPlayer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .padding(.top, 16)
                .background(Color.appBlack)
            }
        }
        .alert("Limite atteinte", isPresented: $showMaxAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.storeService.isPremium
                 ? "Maximum \(vm.maxPlayers) joueurs."
                 : "La version gratuite est limitée à \(GameConfig.freeMaxPlayers) joueurs. Passez Premium pour jouer jusqu'à 8 !")
        }
        .alert("Modifier le joueur", isPresented: $showEditAlert) {
            TextField("Prénom", text: $editedName)
            Button("Valider") {
                if let player = editingPlayer {
                    vm.renamePlayer(id: player.id, newName: editedName)
                }
                editingPlayer = nil
            }
            Button("Annuler", role: .cancel) {
                editingPlayer = nil
            }
        }
    }

    private func addPlayer() {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard vm.players.count < vm.maxPlayers else {
            showMaxAlert = true
            return
        }
        vm.addPlayer(name: newName)
        newName = ""
        fieldFocused = true
    }
}
