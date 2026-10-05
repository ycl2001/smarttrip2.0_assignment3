import SwiftUI

struct SavedPlacesView: View {
    private enum Filter: String, CaseIterable, Identifiable {
        case all
        case idea
        case shortlisted
        case scheduled

        var id: String { rawValue }

        var title: String {
            switch self {
            case .all:
                "All"
            case .idea:
                "Ideas"
            case .shortlisted:
                "Shortlisted"
            case .scheduled:
                "Scheduled"
            }
        }
    }

    let trip: Trip
    @State private var viewModel: SavedPlaceViewModel
    @State private var selectedFilter = Filter.all
    @State private var isShowingAddPlace = false

    init(
        trip: Trip,
        viewModel: SavedPlaceViewModel
    ) {
        self.trip = trip
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

                filterBar

                content
            }
            .padding(SmartTripSpacing.md)
        }
        .background(SmartTripColors.background.ignoresSafeArea())
        .navigationTitle("Saved Places")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingAddPlace = true
                } label: {
                    Label("Add Place", systemImage: "plus")
                }
                .accessibilityLabel("Add saved place")
            }
        }
        .sheet(isPresented: $isShowingAddPlace) {
            AddPlaceSheet(
                trip: trip,
                viewModel: viewModel
            )
        }
        .onAppear {
            viewModel.loadSavedPlaces(for: trip.id)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
            Text(trip.name)
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.primary)
                .textCase(.uppercase)

            Text("Saved Places")
                .font(SmartTripTypography.display)
                .foregroundStyle(SmartTripColors.textPrimary)

            Text("Collect ideas before your group commits them to the itinerary.")
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SmartTripSpacing.sm) {
                ForEach(Filter.allCases) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.title)
                            .font(SmartTripTypography.label)
                            .foregroundStyle(selectedFilter == filter ? .white : SmartTripColors.primary)
                            .padding(.horizontal, SmartTripSpacing.md)
                            .padding(.vertical, SmartTripSpacing.sm)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == filter ? SmartTripColors.primary : SmartTripColors.surface)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading saved places...")
                .frame(maxWidth: .infinity, minHeight: 180)
        } else if viewModel.savedPlaces.isEmpty {
            EmptyStateView(
                systemImage: "bookmark",
                title: "No places saved yet",
                message: "Save places you discover while planning so you can decide what belongs in your itinerary.",
                actionTitle: "Add Place"
            ) {
                isShowingAddPlace = true
            }
        } else if filteredPlaces.isEmpty {
            EmptyStateView(
                systemImage: "line.3.horizontal.decrease.circle",
                title: "No places in this filter",
                message: "Try a different status filter to see more saved places."
            )
        } else {
            LazyVStack(spacing: SmartTripSpacing.md) {
                ForEach(filteredPlaces) { place in
                    NavigationLink {
                        SavedPlaceDetailView(
                            trip: trip,
                            place: place,
                            viewModel: viewModel
                        )
                    } label: {
                        SavedPlaceCard(place: place)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var filteredPlaces: [SavedPlace] {
        switch selectedFilter {
        case .all:
            viewModel.savedPlaces
        case .idea:
            viewModel.savedPlaces.filter { $0.status == .idea }
        case .shortlisted:
            viewModel.savedPlaces.filter { $0.status == .shortlisted }
        case .scheduled:
            viewModel.savedPlaces.filter { $0.status == .scheduled }
        }
    }
}
