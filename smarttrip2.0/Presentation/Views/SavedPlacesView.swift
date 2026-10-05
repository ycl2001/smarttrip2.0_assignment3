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
    @State private var isSelectionMode = false
    @State private var selectedPlaceIDs = Set<UUID>()
    @State private var isShowingBulkPlanner = false

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
            ToolbarItem(placement: .topBarLeading) {
                if isSelectionMode {
                    Button("Cancel") {
                        exitSelectionMode()
                    }
                    .accessibilityLabel("Cancel saved place selection")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                if isSelectionMode {
                    Text("\(selectedPlaceIDs.count) selected")
                        .font(SmartTripTypography.label)
                        .foregroundStyle(SmartTripColors.textSecondary)
                } else if !selectablePlaces.isEmpty {
                    Button("Select") {
                        enterSelectionMode()
                    }
                    .accessibilityLabel("Select saved places")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                if !isSelectionMode {
                    Button {
                        openAddPlace()
                    } label: {
                        Label("Add Place", systemImage: "plus")
                    }
                    .accessibilityLabel("Add saved place")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isSelectionMode {
                selectionActionBar
            }
        }
        .sheet(isPresented: $isShowingAddPlace, onDismiss: {
            viewModel.clearPresentationError()
        }) {
            AddPlaceSheet(
                trip: trip,
                viewModel: viewModel
            )
        }
        .sheet(isPresented: $isShowingBulkPlanner, onDismiss: {
            if selectedPlaceIDs.isEmpty {
                isSelectionMode = false
            }
            viewModel.clearPresentationError()
        }) {
            BulkScheduleView(
                trip: trip,
                places: selectedPlaces,
                viewModel: viewModel
            ) {
                exitSelectionMode()
            }
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
                openAddPlace()
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
                    if isSelectionMode {
                        selectionRow(for: place)
                    } else {
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
    }

    private var selectionActionBar: some View {
        VStack(spacing: SmartTripSpacing.sm) {
            PrimaryActionButton(
                "Plan \(selectedPlaceIDs.count) Selected Place\(selectedPlaceIDs.count == 1 ? "" : "s")",
                systemImage: "calendar.badge.plus"
            ) {
                isShowingBulkPlanner = true
            }
            .disabled(selectedPlaceIDs.isEmpty)
            .accessibilityLabel("Plan \(selectedPlaceIDs.count) selected saved places")

            SecondaryActionButton("Cancel Selection", systemImage: "xmark", isFullWidth: true) {
                exitSelectionMode()
            }
        }
        .padding(SmartTripSpacing.md)
        .background(.regularMaterial)
    }

    private func selectionRow(
        for place: SavedPlace
    ) -> some View {
        let isEligible = place.isBulkPlanningEligible
        let isSelected = selectedPlaceIDs.contains(place.id)

        return Button {
            guard isEligible else {
                return
            }

            toggleSelection(for: place)
        } label: {
            HStack(alignment: .center, spacing: SmartTripSpacing.md) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(isSelected ? SmartTripColors.primary : SmartTripColors.textSecondary)
                    .accessibilityHidden(true)

                SavedPlaceCard(place: place)
                    .opacity(isEligible ? 1 : 0.58)
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEligible)
        .accessibilityLabel(selectionAccessibilityLabel(for: place, isSelected: isSelected, isEligible: isEligible))
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

    private var selectablePlaces: [SavedPlace] {
        viewModel.savedPlaces.filter(\.isBulkPlanningEligible)
    }

    private var selectedPlaces: [SavedPlace] {
        viewModel.savedPlaces
            .filter { selectedPlaceIDs.contains($0.id) }
            .sorted { $0.dateSaved < $1.dateSaved }
    }

    private func openAddPlace() {
        viewModel.clearPresentationError()
        isShowingAddPlace = true
    }

    private func enterSelectionMode() {
        viewModel.clearPresentationError()
        selectedPlaceIDs.removeAll()
        isSelectionMode = true
    }

    private func exitSelectionMode() {
        selectedPlaceIDs.removeAll()
        isSelectionMode = false
        isShowingBulkPlanner = false
        viewModel.clearPresentationError()
    }

    private func toggleSelection(
        for place: SavedPlace
    ) {
        if selectedPlaceIDs.contains(place.id) {
            selectedPlaceIDs.remove(place.id)
        } else {
            selectedPlaceIDs.insert(place.id)
        }
    }

    private func selectionAccessibilityLabel(
        for place: SavedPlace,
        isSelected: Bool,
        isEligible: Bool
    ) -> String {
        if isEligible {
            return "\(place.name), \(isSelected ? "selected" : "not selected") for planning"
        }

        return "\(place.name), \(place.status.displayTitle), not selectable for planning"
    }
}

private extension SavedPlace {
    var isBulkPlanningEligible: Bool {
        status == .idea || status == .shortlisted
    }
}
