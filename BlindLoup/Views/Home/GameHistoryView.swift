import SwiftUI

struct GameHistoryView: View {
    @Environment(\.dismiss) private var dismiss

    private let sortedHistory: [GameSession]

    init() {
        sortedHistory = GameHistoryService.shared.loadHistory()
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Historique")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundStyle(Color.appWhite)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appGrey)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                if sortedHistory.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 52))
                            .foregroundStyle(Color.appNavy)
                        Text("Aucune partie enregistrée")
                            .font(.headline)
                            .foregroundStyle(Color.appGrey)
                        Text("Les résultats de vos prochaines parties\napparaîtront ici.")
                            .font(.subheadline)
                            .foregroundStyle(Color.appGrey.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(sortedHistory) { session in
                                SessionCard(session: session)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }
}

private struct SessionCard: View {
    let session: GameSession

    private var winner: GameSession.PlayerResult? {
        session.players.max(by: { $0.score < $1.score })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date + winner
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Color.appGrey)
                    if let winner {
                        HStack(spacing: 4) {
                            Text("🏆")
                                .font(.caption)
                            Text(winner.name)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.appOrange)
                        }
                    }
                }
                Spacer()
                Text("\(session.players.count) joueurs")
                    .font(.caption)
                    .foregroundStyle(Color.appGrey)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appBlack)
                    .clipShape(Capsule())
            }

            Divider()
                .background(Color.appBlack)

            // Player results sorted by score
            VStack(spacing: 6) {
                ForEach(Array(session.players.sorted { $0.score > $1.score }.enumerated()), id: \.offset) { _, player in
                    HStack {
                        Text(player.name)
                            .font(.subheadline)
                            .foregroundStyle(Color.appWhite)
                        Spacer()
                        Text("\(player.score) pt\(player.score != 1 ? "s" : "")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(player.name == winner?.name ? Color.appOrange : Color.appGrey)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.appNavy)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
