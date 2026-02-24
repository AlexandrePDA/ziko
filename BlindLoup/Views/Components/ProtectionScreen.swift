import SwiftUI

struct ProtectionScreen: View {
    let message: Text
    let onReady: () -> Void

    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            VStack(spacing: 32) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.appOrange)

                message
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                PrimaryButton(title: "Je suis prêt(e)") {
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
