import SwiftUI

struct PlayerScoreRow: View {
    let player: Player
    let rank: Int

    private var pColor: Color { Color.playerColor(player.colorIndex) }

    var body: some View {
        HStack(spacing: 14) {
            Text("#\(rank)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(pColor)
                .frame(width: 32)

            Circle()
                .fill(pColor)
                .frame(width: 10, height: 10)

            Text(player.name)
                .font(.headline)
                .foregroundStyle(Color.appWhite)

            Spacer()

            Text("\(player.score) pt\(player.score != 1 ? "s" : "")")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(pColor)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(pColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(pColor.opacity(0.25), lineWidth: 1)
        )
    }
}
