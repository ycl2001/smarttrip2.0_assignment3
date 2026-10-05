import SwiftUI

struct SavedPlacesOverviewView: View {
    @Environment(\.smartTripDependencies) private var dependencies
    @State private var viewModel: SavedPlacesOverviewViewModel

    init(viewModel: SavedPlacesOverviewViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                header

                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(
                        title: errorMessage,
                        recoverySuggestion: viewModel.recoverySuggestion
                    )
                }

                content
            }
            .padding(SmartTripSpacing.md)
            .padding(.bottom, 84)
        }
        .background(SmartTripColors.background.ignoresSafeArea())
        .onAppear {
            viewModel.load()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
            Text("Saved Places")
                .font(SmartTripTypography.display)
                .foregroundStyle(SmartTripColors.textPrimary)

            Text("Ideas from every trip, grouped by where they belong.")
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading saved places...")
                .frame(maxWidth: .infinity, minHeight: 180)
        } else if viewModel.groups.isEmpty {
            EmptyStateView(
                systemImage: "bookmark",
                title: "No saved places yet",
                message: "Saved places from your trips will appear here."
            )
        } else {
            VStack(alignment: .leading, spacing: SmartTripSpacing.xl) {
                ForEach(viewModel.groups) { group in
                    tripGroup(group)
                }
            }
        }
    }

    private func tripGroup(
        _ group: SavedPlacesOverviewViewModel.TripSavedPlaces
    ) -> some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            SectionHeader(
                group.trip.name,
                subtitle: "\(group.places.count) saved place\(group.places.count == 1 ? "" : "s")"
            )

            ForEach(group.places) { place in
                if let dependencies {
                    NavigationLink {
                        SavedPlaceDetailView(
                            trip: group.trip,
                            place: place,
                            viewModel: dependencies.makeSavedPlaceViewModel()
                        )
                    } label: {
                        overviewCard(
                            place: place,
                            trip: group.trip
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    overviewCard(
                        place: place,
                        trip: group.trip
                    )
                }
            }
        }
    }

    private func overviewCard(
        place: SavedPlace,
        trip: Trip
    ) -> some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
            HStack(alignment: .top, spacing: SmartTripSpacing.md) {
                VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                    Text(place.name)
                        .font(SmartTripTypography.title)
                        .foregroundStyle(SmartTripColors.textPrimary)

                    Text(trip.destination)
                        .font(SmartTripTypography.caption)
                        .foregroundStyle(SmartTripColors.textSecondary)
                        .textCase(.uppercase)
                }

                Spacer()

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
                    .lineLimit(2)
            }
        }
        .padding(SmartTripSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(place.name), \(trip.name), \(place.status.displayTitle)")
    }
}
