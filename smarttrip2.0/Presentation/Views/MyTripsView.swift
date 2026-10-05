import SwiftUI

struct MyTripsView: View {
    @Environment(\.smartTripDependencies) private var dependencies
    @State private var viewModel: TripViewModel
    @State private var isShowingCreateTrip = false

    init(viewModel: TripViewModel) {
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
        }
        .background(SmartTripColors.background.ignoresSafeArea())
        .navigationTitle("Trips")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingCreateTrip = true
                } label: {
                    Label("Create Trip", systemImage: "plus")
                }
                .accessibilityLabel("Create trip")
            }
        }
        .sheet(isPresented: $isShowingCreateTrip, onDismiss: {
            viewModel.clearPresentationError()
        }) {
            CreateTripSheet(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadTrips()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
            Text("SmartTrip 2.0")
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.primary)
                .textCase(.uppercase)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                    Text("My Trips")
                        .font(SmartTripTypography.display)
                        .foregroundStyle(SmartTripColors.textPrimary)

                    Text("Plan together, save ideas, and keep every trip moving.")
                        .font(SmartTripTypography.body)
                        .foregroundStyle(SmartTripColors.textSecondary)
                }

                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading your trips...")
                .frame(maxWidth: .infinity, minHeight: 180)
        } else if viewModel.trips.isEmpty {
            EmptyStateView(
                systemImage: "suitcase.rolling",
                title: "No trips yet",
                message: "Create a trip to start collecting places and planning your itinerary.",
                actionTitle: "Create Trip"
            ) {
                isShowingCreateTrip = true
            }
        } else {
            tripSections
        }
    }

    private var tripSections: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.xl) {
            if !currentAndUpcomingTrips.isEmpty {
                tripSection(
                    title: "Current & Upcoming",
                    subtitle: "\(currentAndUpcomingTrips.count) trip\(currentAndUpcomingTrips.count == 1 ? "" : "s") ready for planning",
                    trips: currentAndUpcomingTrips
                )
            }

            if !pastTrips.isEmpty {
                tripSection(
                    title: "Past Trips",
                    subtitle: "Journeys you can revisit later",
                    trips: pastTrips
                )
            }
        }
    }

    private func tripSection(
        title: String,
        subtitle: String,
        trips: [Trip]
    ) -> some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            SectionHeader(title, subtitle: subtitle)

            ForEach(trips) { trip in
                NavigationLink {
                    if let dependencies {
                        TripHubView(
                            trip: trip,
                            viewModel: dependencies.makeTripHubViewModel(
                                tripID: trip.id
                            )
                        )
                    } else {
                        TripHubView(
                            trip: trip,
                            viewModel: nil
                        )
                    }
                } label: {
                    TripCard(trip: trip)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(trip.name), \(trip.destination). Opens trip.")
            }
        }
    }

    private var currentAndUpcomingTrips: [Trip] {
        let today = Calendar.current.startOfDay(for: Date())

        return viewModel.trips
            .filter { Calendar.current.startOfDay(for: $0.endDate) >= today }
            .sorted { $0.startDate < $1.startDate }
    }

    private var pastTrips: [Trip] {
        let today = Calendar.current.startOfDay(for: Date())

        return viewModel.trips
            .filter { Calendar.current.startOfDay(for: $0.endDate) < today }
            .sorted { $0.endDate > $1.endDate }
    }
}
