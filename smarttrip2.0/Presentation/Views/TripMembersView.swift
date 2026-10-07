import SwiftUI

struct TripMembersView: View {
    let trip: Trip

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                tripContext
                organiserCard
                inviteSection
            }
            .padding(SmartTripSpacing.md)
        }
        .background(SmartTripColors.background.ignoresSafeArea())
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var tripContext: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
            Text(trip.destination)
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.primary)
                .textCase(.uppercase)

            Text(trip.name)
                .font(SmartTripTypography.display)
                .foregroundStyle(SmartTripColors.textPrimary)

            Text(dateRangeText)
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
    }

    private var organiserCard: some View {
        HStack(spacing: SmartTripSpacing.md) {
            Text("Y")
                .font(.title3.weight(.bold))
                .foregroundStyle(SmartTripColors.primary)
                .frame(width: 52, height: 52)
                .background(Circle().fill(SmartTripColors.primary.opacity(0.14)))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                Text("You")
                    .font(SmartTripTypography.headline)
                    .foregroundStyle(SmartTripColors.textPrimary)

                Text("Trip organiser")
                    .font(SmartTripTypography.body)
                    .foregroundStyle(SmartTripColors.textSecondary)
            }

            Spacer()
        }
        .padding(SmartTripSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
        )
        .accessibilityElement(children: .combine)
    }

    private var inviteSection: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            Text("Invite people to this trip")
                .font(SmartTripTypography.title)
                .foregroundStyle(SmartTripColors.textPrimary)

            Text("Share a trip invitation using your preferred app.")
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)

            ShareLink(
                item: inviteMessage,
                subject: Text("Join my \(trip.name) trip"),
                message: Text("You're invited to join my trip on SmartTrip.")
            ) {
                Label("Invite Member", systemImage: "square.and.arrow.up")
                    .font(SmartTripTypography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SmartTripSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: SmartTripRadius.medium, style: .continuous)
                            .fill(SmartTripColors.primary)
                    )
            }
            .accessibilityLabel("Invite Member")
        }
        .padding(SmartTripSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
        )
    }

    private var inviteMessage: String {
        "You're invited to join my \(trip.name) trip on SmartTrip.\n\n\(trip.destination)\n\(dateRangeText)"
    }

    private var dateRangeText: String {
        "\(trip.startDate.formatted(.dateTime.day().month(.abbreviated).year())) – \(trip.endDate.formatted(.dateTime.day().month(.abbreviated).year()))"
    }
}
