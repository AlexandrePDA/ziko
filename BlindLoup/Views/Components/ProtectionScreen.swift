import SwiftUI

struct ProtectionScreen: View {
    @Environment(GameViewModel.self) private var vm
    let message: Text
    let onReady: () -> Void

    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            VStack(spacing: 32) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(vm.themeColor)
                    .accessibilityHidden(true)

                message
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                PrimaryButton(title: "Je suis prêt(e)", color: vm.themeColor, textColor: .appBackground) {
                    onReady()
                }
                .padding(.horizontal, 32)
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.4)) {
                opacity = 1
            }
        }
    }
}
