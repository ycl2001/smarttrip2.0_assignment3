import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let systemImage: String?
    var isFullWidth = true
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        isFullWidth: Bool = true,
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
        .buttonStyle(PrimaryActionButtonStyle())
    }
}

private struct PrimaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SmartTripTypography.label)
            .foregroundStyle(.white)
            .padding(.horizontal, SmartTripSpacing.lg)
            .frame(minHeight: 52)
            .background(
                Capsule()
                    .fill(isEnabled ? SmartTripColors.primary : SmartTripColors.divider)
            )
            .opacity(configuration.isPressed ? 0.82 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .accessibilityAddTraits(.isButton)
    }
}

#Preview("Primary Action Button") {
    VStack(spacing: SmartTripSpacing.md) {
        PrimaryActionButton("Create Trip", systemImage: "plus") {}
        PrimaryActionButton("Disabled", systemImage: "lock") {}
            .disabled(true)
    }
    .padding()
    .background(SmartTripColors.background)
}
