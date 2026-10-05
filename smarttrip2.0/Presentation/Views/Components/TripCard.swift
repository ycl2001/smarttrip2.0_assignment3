import SwiftUI

struct TripCard: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover

            VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
                VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                    Text(trip.destination)
                        .font(SmartTripTypography.caption)
                        .foregroundStyle(SmartTripColors.primary)
                        .textCase(.uppercase)

                    Text(trip.name)
                        .font(SmartTripTypography.title)
                        .foregroundStyle(SmartTripColors.textPrimary)
                        .lineLimit(2)
                }

                HStack(spacing: SmartTripSpacing.sm) {
                    Label(dateRangeText, systemImage: "calendar")
                        .font(SmartTripTypography.body)
                        .foregroundStyle(SmartTripColors.textSecondary)

                    Spacer(minLength: SmartTripSpacing.sm)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SmartTripColors.primary)
                        .accessibilityHidden(true)
                }
            }
            .padding(SmartTripSpacing.md)
        }
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
                .shadow(color: SmartTripColors.primary.opacity(0.08), radius: 14, x: 0, y: 6)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var cover: some View {
        if let coverImageName = trip.coverImageName {
            Image(coverImageName)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .accessibilityHidden(true)
        } else {
            LinearGradient(
                colors: [
                    SmartTripColors.primary,
                    SmartTripColors.accent.opacity(0.72),
                    SmartTripColors.highlight.opacity(0.62)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 150)
            .overlay(alignment: .bottomLeading) {
                Image(systemName: "map.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.88))
                    .padding(SmartTripSpacing.md)
                    .accessibilityHidden(true)
            }
        }
    }

    private var dateRangeText: String {
        "\(Self.dateFormatter.string(from: trip.startDate)) - \(Self.dateFormatter.string(from: trip.endDate))"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
}

#Preview("Trip Card") {
    TripCard(
        trip: Trip(
            name: "Tokyo Graduation Trip",
            destination: "Tokyo",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
        )
    )
    .padding()
    .background(SmartTripColors.background)
}
