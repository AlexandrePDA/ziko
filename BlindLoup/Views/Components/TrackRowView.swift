import SwiftUI

struct TrackRowView: View {
    let track: Track
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: track.albumCoverURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.appNavy
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appWhite)
                    .lineLimit(1)
                Text(track.artist)
                    .font(.caption)
                    .foregroundStyle(Color.appGrey)
                    .lineLimit(1)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.appOrange)
                    .font(.title3)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
