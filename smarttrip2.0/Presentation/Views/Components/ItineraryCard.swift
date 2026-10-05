import SwiftUI

struct ItineraryCard: View {
    let item: ItineraryItem

    var body: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            HStack(alignment: .top, spacing: SmartTripSpacing.md) {
                VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                    Text(timeText)
                        .font(SmartTripTypography.caption)
                        .foregroundStyle(SmartTripColors.primary)
                        .textCase(.uppercase)

                    Text(item.title)
                        .font(SmartTripTypography.title)
                        .foregroundStyle(SmartTripColors.textPrimary)
                        .lineLimit(2)
                }

                Spacer(minLength: SmartTripSpacing.sm)

                StatusChip(
                    item.category.rawValue.capitalized,
                    systemImage: categoryIcon,
                    style: .neutral
                )
            }

            Label(item.location, systemImage: "location")
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)

            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(SmartTripTypography.body)
                    .foregroundStyle(SmartTripColors.textSecondary)
                    .lineLimit(3)
            }
        }
        .padding(SmartTripSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
                .shadow(color: SmartTripColors.primary.opacity(0.06), radius: 14, x: 0, y: 6)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.location), \(timeText)")
    }

    private var timeText: String {
        guard let startTime = item.startTime else {
            return "Time not set"
        }

        if let endTime = item.endTime {
            return "\(Self.timeFormatter.string(from: startTime)) - \(Self.timeFormatter.string(from: endTime))"
        }

        return Self.timeFormatter.string(from: startTime)
    }

    private var categoryIcon: String {
        switch item.category {
        case .attraction:
            "camera"
        case .food:
            "fork.knife"
        case .transport:
            "tram"
        case .accommodation:
            "bed.double"
        case .shopping:
            "bag"
        case .activity:
            "figure.walk"
        case .other:
            "calendar"
        }
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}
