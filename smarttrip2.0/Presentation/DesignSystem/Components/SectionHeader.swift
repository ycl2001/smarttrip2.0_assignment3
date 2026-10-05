import SwiftUI

struct SectionHeader: View {
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        _ title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SmartTripSpacing.md) {
            VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                Text(title)
                    .font(SmartTripTypography.title)
                    .foregroundStyle(SmartTripColors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(SmartTripTypography.body)
                        .foregroundStyle(SmartTripColors.textSecondary)
                }
            }

            Spacer(minLength: SmartTripSpacing.md)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(SmartTripTypography.label)
                    .foregroundStyle(SmartTripColors.primary)
            }
        }
    }
}

#Preview("Section Header") {
    VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
        SectionHeader(
            "Saved Places",
            subtitle: "Ideas your group is considering",
            actionTitle: "Add"
        ) {}

        SectionHeader("Itinerary")
    }
    .padding()
    .background(SmartTripColors.background)
}
