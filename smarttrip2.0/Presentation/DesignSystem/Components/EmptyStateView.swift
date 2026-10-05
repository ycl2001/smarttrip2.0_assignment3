import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        systemImage: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: SmartTripSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(SmartTripColors.primary)
                .frame(width: 72, height: 72)
                .background(
                    Circle()
                        .fill(SmartTripColors.accent.opacity(0.14))
                )
                .accessibilityHidden(true)

            VStack(spacing: SmartTripSpacing.sm) {
                Text(title)
                    .font(SmartTripTypography.title)
                    .foregroundStyle(SmartTripColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(SmartTripTypography.body)
                    .foregroundStyle(SmartTripColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                PrimaryActionButton(actionTitle, action: action)
                    .padding(.top, SmartTripSpacing.sm)
            }
        }
        .padding(SmartTripSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
        )
    }
}

#Preview("Empty State") {
    EmptyStateView(
        systemImage: "suitcase.rolling",
        title: "No trips yet",
        message: "Create your first collaborative trip workspace.",
        actionTitle: "Create Trip"
    ) {}
    .padding()
    .background(SmartTripColors.background)
}
