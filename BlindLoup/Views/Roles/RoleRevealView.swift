import SwiftUI

// MARK: - RoleRevealView (phase view)

struct RoleRevealView: View {
    @Environment(GameViewModel.self) private var vm
    let playerIndex: Int

    private var player: Player? {
        vm.players.indices.contains(playerIndex) ? vm.players[playerIndex] : nil
    }

    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()

            if let player, let role = vm.role(for: player.id) {
                RoleRevealContent(player: player, role: role)
            }
        }
    }
}

// MARK: - RoleRevealContent

private struct RoleRevealContent: View {
    @Environment(GameViewModel.self) private var vm
    let player: Player
    let role: RoleType

    @State private var cardVisible = false
    @State private var showSuspectPicker = false
    @State private var selectedSuspect: Player? = nil

    private var canAdvance: Bool {
        role != .obsessionnel || selectedSuspect != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Text("Ton rôle secret")
                    .font(.caption)
                    .fontWeight(.black)
                    .kerning(1.5)
                    .foregroundStyle(Color.appGrey)
                    .padding(.top, 52)

                (Text(player.name).foregroundStyle(Color.playerColor(player.colorIndex))
                 + Text(", voici ta mission.").foregroundStyle(Color.appWhite))
                    .font(.title3.weight(.black))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            Spacer()

            // Role card
            RoleCard(role: role)
                .padding(.horizontal, 24)
                .scaleEffect(cardVisible ? 1 : 0.85)
                .opacity(cardVisible ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.1), value: cardVisible)

            Spacer()

            // Obsessionnel suspect picker
            if role == .obsessionnel {
                suspectSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }

            // CTA
            Button(action: advance) {
                Text(role == .obsessionnel && selectedSuspect == nil
                     ? "Choisis ton suspect d'abord"
                     : "Choisir mes musiques")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(canAdvance ? Color.appBackground : Color.appGrey)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canAdvance ? role.accentColor : Color.appSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!canAdvance)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .animation(.easeInOut(duration: 0.2), value: canAdvance)
        }
        .onAppear { cardVisible = true }
    }

    @ViewBuilder
    private var suspectSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choisis ton suspect")
                .font(.caption)
                .fontWeight(.black)
                .kerning(1.3)
                .foregroundStyle(Color.appGrey)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(vm.players.filter { $0.id != player.id }) { suspect in
                        let isSelected = selectedSuspect?.id == suspect.id
                        let pColor = Color.playerColor(suspect.colorIndex)

                        Button(action: {
                            selectedSuspect = suspect
                            vm.setSuspect(suspect.id, for: player.id)
                        }) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(pColor)
                                    .frame(width: 10, height: 10)
                                Text(suspect.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(isSelected ? Color.appBackground : Color.appWhite)
                                    .lineLimit(1)
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color.appBackground)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(isSelected ? pColor : pColor.opacity(0.15))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .strokeBorder(pColor.opacity(isSelected ? 0 : 0.4), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut(duration: 0.15), value: isSelected)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(14)
        .background(RoleType.obsessionnel.accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(RoleType.obsessionnel.accentColor.opacity(0.2), lineWidth: 1)
        )
    }

    private func advance() {
        guard canAdvance else { return }
        vm.advancePhase()
    }
}

// MARK: - RoleCard

struct RoleCard: View {
    let role: RoleType
    @State private var glowAnimate = false

    var body: some View {
        VStack(spacing: 0) {
            // Top colored band
            ZStack {
                role.accentColor.opacity(0.18)

                // Glow blobs
                Circle()
                    .fill(role.accentColor.opacity(0.35))
                    .frame(width: 120)
                    .blur(radius: 30)
                    .offset(x: glowAnimate ? -20 : 20, y: glowAnimate ? -10 : 10)
                Circle()
                    .fill(role.accentColor.opacity(0.2))
                    .frame(width: 80)
                    .blur(radius: 20)
                    .offset(x: glowAnimate ? 30 : -30, y: glowAnimate ? 15 : -15)

                VStack(spacing: 12) {
                    Text(role.emoji)
                        .font(.system(size: 64))
                        .scaleEffect(glowAnimate ? 1.06 : 0.95)
                        .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: glowAnimate)

                    Text(role.title.uppercased())
                        .font(.caption)
                        .fontWeight(.black)
                        .kerning(2)
                        .foregroundStyle(role.accentColor)
                }
                .padding(.vertical, 32)
            }
            .frame(height: 180)
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 20, bottomLeadingRadius: 0,
                bottomTrailingRadius: 0, topTrailingRadius: 20
            ))

            // Bottom content
            VStack(alignment: .leading, spacing: 14) {
                Text(role.tagline)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appWhite)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                    .background(role.accentColor.opacity(0.2))

                VStack(alignment: .leading, spacing: 8) {
                    Label("Mission", systemImage: "scope")
                        .font(.caption)
                        .fontWeight(.black)
                        .kerning(1.2)
                        .foregroundStyle(role.accentColor)

                    Text(role.mission)
                        .font(.caption)
                        .foregroundStyle(Color.appGreyLight)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()
                    .background(role.accentColor.opacity(0.2))

                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(role.accentColor)
                    Text(role.bonusLabel)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(role.accentColor)
                }
            }
            .padding(20)
            .background(Color.appSurface)
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 0, bottomLeadingRadius: 20,
                bottomTrailingRadius: 20, topTrailingRadius: 0
            ))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(role.accentColor.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: role.accentColor.opacity(0.2), radius: 20, y: 8)
        .onAppear { glowAnimate = true }
    }
}
