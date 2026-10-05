import SwiftUI

struct SecondaryActionButton: View {
    let title: String
    let systemImage: String?
    var isFullWidth = false
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isFullWidth = isFullWidth
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                if let systemImage {
                    Image(systemName: systemImage)
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
        }
        .buttonStyle(SecondaryActionButtonStyle())
    }
}

private struct SecondaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SmartTripTypography.label)
            .foregroundStyle(isEnabled ? SmartTripColors.primary : SmartTripColors.textSecondary)
            .padding(.horizontal, SmartTripSpacing.lg)
            .frame(minHeight: 48)
            .background(
                Capsule()
                    .fill(SmartTripColors.surface)
            )
            .overlay(
                Capsule()
                    .stroke(isEnabled ? SmartTripColors.primary.opacity(0.22) : SmartTripColors.divider)
            )
            .opacity(configuration.isPressed ? 0.78 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .accessibilityAddTraits(.isButton)
    }
}

#Preview("Secondary Action Button") {
    VStack(spacing: SmartTripSpacing.md) {
        SecondaryActionButton("Cancel", systemImage: "xmark") {}
        SecondaryActionButton("Edit", systemImage: "pencil", isFullWidth: true) {}
    }
    .padding()
    .background(SmartTripColors.background)
}
