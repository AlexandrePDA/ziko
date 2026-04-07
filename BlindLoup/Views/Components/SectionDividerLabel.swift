import SwiftUI

/// Séparateur horizontal avec libellé centré — ex. "SCORE", "BONUS PARTIE".
struct SectionDividerLabel: View {
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Rectangle()
                .fill(color.opacity(0.4))
                .frame(height: 1)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .fixedSize()
            Rectangle()
                .fill(color.opacity(0.4))
                .frame(height: 1)
        }
    }
}
