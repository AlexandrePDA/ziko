import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.appWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.appOrange)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .opacity(isDisabled ? 0.4 : 1)
        }
        .disabled(isDisabled)
    }
}
