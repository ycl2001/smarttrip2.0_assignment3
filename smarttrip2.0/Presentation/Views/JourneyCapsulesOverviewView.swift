import SwiftUI

struct JourneyCapsulesOverviewView: View {
    @State private var viewModel: TripViewModel
    let dependencies: SmartTripDependencies

    init(
        viewModel: TripViewModel,
        dependencies: SmartTripDependencies
    ) {
        _viewModel = State(initialValue: viewModel)
        self.dependencies = dependencies
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
            viewModel.loadTrips()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
            Text("Journey Capsules")
                .font(SmartTripTypography.display)
                .foregroundStyle(SmartTripColors.textPrimary)

            Text("Moments from the trips you've taken.")
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading journey capsules...")
                .frame(maxWidth: .infinity, minHeight: 180)
        } else if viewModel.trips.isEmpty {
            EmptyStateView(
                systemImage: "photo.on.rectangle",
                title: "No capsules yet",
                message: "Create a trip to start a Journey Capsule."
            )
        } else {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: SmartTripSpacing.md),
                    GridItem(.flexible(), spacing: SmartTripSpacing.md)
                ],
                spacing: SmartTripSpacing.lg
            ) {
                ForEach(viewModel.trips.sorted { $0.startDate > $1.startDate }) { trip in
                    NavigationLink {
                        JourneyCapsuleView(
                            trip: trip,
                            viewModel: dependencies.makeJourneyCapsuleViewModel(
                                tripID: trip.id
                            )
                        )
                    } label: {
                        capsuleTile(for: trip)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open Journey Capsule for \(trip.name)")
                }
            }
        }
    }

    private func capsuleTile(
        for trip: Trip
    ) -> some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
            capsuleCover(for: trip)
                .aspectRatio(0.82, contentMode: .fit)
                .clipShape(
                    RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                )

            VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                Text(trip.destination)
                    .font(SmartTripTypography.headline)
                    .foregroundStyle(SmartTripColors.textPrimary)
                    .lineLimit(1)

                Text(dateRangeText(for: trip))
                    .font(SmartTripTypography.caption)
                    .foregroundStyle(SmartTripColors.textSecondary)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private func capsuleCover(
        for trip: Trip
    ) -> some View {
        if let coverImageName = trip.coverImageName {
            Image(coverImageName)
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)
        } else {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [
                        SmartTripColors.deepBrown,
                        SmartTripColors.primary,
                        SmartTripColors.highlight.opacity(0.72)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                    Text(String(trip.destination.prefix(1)))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white.opacity(0.92))

                    Text(trip.name)
                        .font(SmartTripTypography.caption)
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(2)
                }
                .padding(SmartTripSpacing.md)
            }
        }
    }

    private func dateRangeText(
        for trip: Trip
    ) -> String {
        "\(Self.dateFormatter.string(from: trip.startDate)) - \(Self.dateFormatter.string(from: trip.endDate))"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
}
