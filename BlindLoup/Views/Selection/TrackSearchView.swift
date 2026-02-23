import SwiftUI

struct TrackSearchView: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    let playerID: UUID

    @State private var searchVM = SearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBlack.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.appGrey)
                        TextField("Rechercher une chanson...", text: $searchVM.searchText)
                            .foregroundStyle(Color.appWhite)
                            .tint(Color.appOrange)
                            .autocorrectionDisabled()
                        if !searchVM.searchText.isEmpty {
                            Button(action: searchVM.clearSearch) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.appGrey)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.appNavy)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                    // Results
                    switch searchVM.state {
                    case .idle:
                        Spacer()
                        Text("Cherche un titre ou un artiste")
                            .foregroundStyle(Color.appGrey)
                        Spacer()

                    case .loading:
                        Spacer()
                        ProgressView()
                            .tint(Color.appOrange)
                        Spacer()

                    case .loaded(let tracks):
                        List(tracks) { track in
                            let selected = vm.tracksForPlayer(playerID).contains(where: { $0.id == track.id })
                            TrackRowView(track: track, isSelected: selected)
                                .listRowBackground(Color.appNavy)
                                .listRowSeparatorTint(Color.appBlack)
                                .onTapGesture {
                                    if !selected {
                                        vm.addTrack(track, to: playerID)
                                        dismiss()
                                    }
                                }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)

                    case .error(let msg):
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "wifi.slash")
                                .font(.largeTitle)
                                .foregroundStyle(Color.appGrey)
                            Text(msg)
                                .foregroundStyle(Color.appGrey)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Ajouter un morceau")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(Color.appOrange)
                }
            }
        }
    }
}
