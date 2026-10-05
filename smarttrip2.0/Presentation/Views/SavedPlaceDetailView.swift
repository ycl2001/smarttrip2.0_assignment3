import SwiftUI

struct SavedPlaceDetailView: View {
    let trip: Trip
    let place: SavedPlace
    let viewModel: SavedPlaceViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
                    StatusChip(
                        place.status.displayTitle,
                        systemImage: place.status.systemImage,
                        style: place.status.chipStyle
                    )

                    Text(place.name)
                        .font(SmartTripTypography.display)
                        .foregroundStyle(SmartTripColors.textPrimary)

                    if let url = place.url {
                        Link(destination: url) {
                            Label(url.absoluteString, systemImage: "link")
                                .font(SmartTripTypography.body)
                                .foregroundStyle(SmartTripColors.primary)
                                .lineLimit(2)
                        }
                    }
                }

                if let notes = place.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
                        SectionHeader("Notes")
                        Text(notes)
                            .font(SmartTripTypography.body)
                            .foregroundStyle(SmartTripColors.textSecondary)
                    }
                    .padding(SmartTripSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                            .fill(SmartTripColors.surface)
                    )
                }

                if place.status == .scheduled {
                    EmptyStateView(
                        systemImage: "calendar.badge.checkmark",
                        title: "Already scheduled",
                        message: "This place has already been added to the trip itinerary."
                    )
                } else {
                    EmptyStateView(
                        systemImage: "calendar.badge.plus",
                        title: "Ready to schedule",
                        message: "Choose a date and time when your group is ready to commit this place to the itinerary."
                    )
                }
            }
            .padding(SmartTripSpacing.md)
        }
        .background(SmartTripColors.background)
        .navigationTitle("Saved Place")
        .navigationBarTitleDisplayMode(.inline)
    }
}
