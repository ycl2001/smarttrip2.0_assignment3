import SwiftUI

struct SavedPlaceCard: View {
    let place: SavedPlace

    var body: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            HStack(alignment: .top, spacing: SmartTripSpacing.md) {
                VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                    Text(place.name)
                        .font(SmartTripTypography.title)
                        .foregroundStyle(SmartTripColors.textPrimary)
                        .lineLimit(2)

                    if let url = place.url {
                        Label(url.host() ?? url.absoluteString, systemImage: "link")
                            .font(SmartTripTypography.caption)
                            .foregroundStyle(SmartTripColors.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: SmartTripSpacing.sm)

                StatusChip(
                    place.status.displayTitle,
                    systemImage: place.status.systemImage,
                    style: place.status.chipStyle
                )
            }

            if let notes = place.notes, !notes.isEmpty {
                Text(notes)
                    .font(SmartTripTypography.body)
                    .foregroundStyle(SmartTripColors.textSecondary)
                    .lineLimit(3)
            }

            Label("Saved \(Self.dateFormatter.string(from: place.dateSaved))", systemImage: "calendar")
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
        .padding(SmartTripSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
                .shadow(color: SmartTripColors.primary.opacity(0.06), radius: 14, x: 0, y: 6)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(place.name), \(place.status.displayTitle)")
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

extension SavedPlaceStatus {
    var displayTitle: String {
        switch self {
        case .idea:
            "Idea"
        case .shortlisted:
            "Shortlisted"
        case .scheduled:
            "Scheduled"
        case .rejected:
            "Rejected"
        }
    }

    var systemImage: String {
        switch self {
        case .idea:
            "lightbulb"
        case .shortlisted:
            "star"
        case .scheduled:
            "calendar.badge.checkmark"
        case .rejected:
            "xmark.circle"
        }
    }

    var chipStyle: StatusChip.Style {
        switch self {
        case .idea:
            .idea
        case .shortlisted:
            .shortlisted
        case .scheduled:
            .scheduled
        case .rejected:
            .rejected
        }
    }
}
