import SwiftUI

struct ErrorBanner: View {
    let title: String
    let recoverySuggestion: String?

    init(
        title: String,
        recoverySuggestion: String? = nil
    ) {
        self.title = title
        self.recoverySuggestion = recoverySuggestion
    }

    var body: some View {
        HStack(alignment: .top, spacing: SmartTripSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(SmartTripColors.error)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                Text(title)
                    .font(SmartTripTypography.label)
                    .foregroundStyle(SmartTripColors.textPrimary)

                if let recoverySuggestion, !recoverySuggestion.isEmpty {
                    Text(recoverySuggestion)
                        .font(SmartTripTypography.body)
                        .foregroundStyle(SmartTripColors.textSecondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(SmartTripSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.medium, style: .continuous)
                .fill(SmartTripColors.error.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: SmartTripRadius.medium, style: .continuous)
                .stroke(SmartTripColors.error.opacity(0.18))
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview("Error Banner") {
    ErrorBanner(
        title: "The trip cannot end before it starts.",
        recoverySuggestion: "Choose an end date that is the same as or later than the start date."
    )
    .padding()
    .background(SmartTripColors.background)
}
