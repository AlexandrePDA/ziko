import SwiftUI

struct PrimaryButton: View {
    @Environment(SoundService.self) private var sound

    let title: String
    var color: Color = Color.appOrange
    var textColor: Color = Color.appWhite
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: { sound.playTap(); action() }) {
            Text(title)
                .font(.headline)
                .foregroundStyle(textColor)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .opacity(isDisabled ? 0.4 : 1)
        }
        .disabled(isDisabled)
    }
}
