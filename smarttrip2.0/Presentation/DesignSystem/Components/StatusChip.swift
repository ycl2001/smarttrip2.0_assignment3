import SwiftUI

struct StatusChip: View {
    struct Style {
        let foreground: Color
        let background: Color

        static let neutral = Style(
            foreground: SmartTripColors.textSecondary,
            background: SmartTripColors.surfaceMuted
        )

        static let idea = Style(
            foreground: SmartTripColors.primary,
            background: SmartTripColors.accent.opacity(0.16)
        )

        static let shortlisted = Style(
            foreground: SmartTripColors.deepBrown,
            background: SmartTripColors.highlight.opacity(0.28)
        )

        static let scheduled = Style(
            foreground: SmartTripColors.success,
            background: SmartTripColors.success.opacity(0.14)
        )

        static let rejected = Style(
            foreground: SmartTripColors.error,
            background: SmartTripColors.error.opacity(0.12)
        )
    }

    let title: String
    let systemImage: String?
    let style: Style

    init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .neutral
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
    }

    var body: some View {
        Label {
            Text(title)
        } icon: {
            if let systemImage {
                Image(systemName: systemImage)
            }
        }
        .font(SmartTripTypography.caption)
        .foregroundStyle(style.foreground)
        .padding(.horizontal, SmartTripSpacing.sm)
        .padding(.vertical, SmartTripSpacing.xs)
        .background(
            Capsule()
                .fill(style.background)
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview("Status Chips") {
    VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
        StatusChip("Idea", systemImage: "lightbulb", style: .idea)
        StatusChip("Shortlisted", systemImage: "star", style: .shortlisted)
        StatusChip("Scheduled", systemImage: "calendar.badge.checkmark", style: .scheduled)
        StatusChip("Rejected", systemImage: "xmark.circle", style: .rejected)
    }
    .padding()
    .background(SmartTripColors.background)
}
