import SwiftUI

struct SmartTripRootView: View {
    enum RootPage {
        case home
        case savedPlaces
        case capsules
    }

    let dependencies: SmartTripDependencies

    @State private var selectedPage = RootPage.home
    @State private var tripViewModel: TripViewModel
    @State private var savedPlacesOverviewViewModel: SavedPlacesOverviewViewModel
    @State private var isShowingCreateTrip = false
    @State private var isShowingSettings = false
    @State private var routedJourneyCapsuleTrip: Trip?
    @State private var notificationRouter = JourneyCapsuleNotificationRouter.shared

    init(dependencies: SmartTripDependencies) {
        self.dependencies = dependencies
        _tripViewModel = State(initialValue: dependencies.makeTripViewModel())
        _savedPlacesOverviewViewModel = State(initialValue: dependencies.makeSavedPlacesOverviewViewModel())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                topBar

                rootContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(SmartTripColors.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                SmartTripBottomBar(
                    selectedPage: selectedPage,
                    onTrips: {
                        selectedPage = .home
                    },
                    onSavedPlaces: {
                        selectedPage = .savedPlaces
                    },
                    onCreateTrip: {
                        tripViewModel.clearPresentationError()
                        isShowingCreateTrip = true
                    },
                    onCapsules: {
                        selectedPage = .capsules
                    }
                )
            }
            .sheet(isPresented: $isShowingCreateTrip, onDismiss: {
                tripViewModel.clearPresentationError()
                tripViewModel.loadTrips()
            }) {
                CreateTripSheet(viewModel: tripViewModel)
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .navigationDestination(isPresented: isShowingRoutedJourneyCapsule) {
                if let routedJourneyCapsuleTrip {
                    JourneyCapsuleView(
                        trip: routedJourneyCapsuleTrip,
                        viewModel: dependencies.makeJourneyCapsuleViewModel(
                            tripID: routedJourneyCapsuleTrip.id
                        )
                    )
                }
            }
            .onAppear {
                handlePendingJourneyCapsuleRoute()
            }
            .onChange(of: notificationRouter.pendingJourneyCapsuleTripID) { _, tripID in
                guard tripID != nil else {
                    return
                }

                handlePendingJourneyCapsuleRoute()
            }
        }
        .tint(SmartTripColors.primary)
    }

    private var isShowingRoutedJourneyCapsule: Binding<Bool> {
        Binding {
            routedJourneyCapsuleTrip != nil
        } set: { isPresented in
            if !isPresented {
                routedJourneyCapsuleTrip = nil
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                selectedPage = .home
            } label: {
                HStack(spacing: SmartTripSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(SmartTripColors.primary)

                        Image(systemName: "map.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 34, height: 34)
                    .accessibilityHidden(true)

                    Text("SmartTrip")
                        .font(SmartTripTypography.headline)
                        .foregroundStyle(SmartTripColors.textPrimary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("SmartTrip Home")

            Spacer()

            Button {
                isShowingSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(SmartTripColors.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, SmartTripSpacing.md)
        .padding(.top, SmartTripSpacing.sm)
        .padding(.bottom, SmartTripSpacing.xs)
        .background(SmartTripColors.background)
    }

    @ViewBuilder
    private var rootContent: some View {
        switch selectedPage {
        case .home:
            MyTripsView(
                viewModel: tripViewModel,
                onCreateTrip: {
                    tripViewModel.clearPresentationError()
                    isShowingCreateTrip = true
                }
            )
        case .savedPlaces:
            SavedPlacesOverviewView(
                viewModel: savedPlacesOverviewViewModel
            )
        case .capsules:
            JourneyCapsulesOverviewView(
                viewModel: tripViewModel,
                dependencies: dependencies
            )
        }
    }

    private func handlePendingJourneyCapsuleRoute() {
        guard let tripID = notificationRouter.consumePendingJourneyCapsuleTripID() else {
            return
        }

        selectedPage = .capsules
        tripViewModel.loadTrips()

        guard let trip = tripViewModel.trips.first(where: { $0.id == tripID }) else {
            routedJourneyCapsuleTrip = nil
            return
        }

        routedJourneyCapsuleTrip = trip
    }
}

private struct SmartTripBottomBar: View {
    let selectedPage: SmartTripRootView.RootPage
    let onTrips: () -> Void
    let onSavedPlaces: () -> Void
    let onCreateTrip: () -> Void
    let onCapsules: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            bottomButton(
                title: "Trips",
                systemImage: selectedPage == .home ? "suitcase.fill" : "suitcase",
                isSelected: selectedPage == .home,
                accessibilityLabel: "Trips",
                action: onTrips
            )

            Spacer(minLength: SmartTripSpacing.xs)

            bottomButton(
                title: "Saved",
                systemImage: selectedPage == .savedPlaces ? "bookmark.fill" : "bookmark",
                isSelected: selectedPage == .savedPlaces,
                accessibilityLabel: "Saved Places",
                action: onSavedPlaces
            )

            Spacer(minLength: SmartTripSpacing.xs)

            Button(action: onCreateTrip) {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(
                        Circle()
                            .fill(SmartTripColors.primary)
                            .shadow(color: SmartTripColors.primary.opacity(0.24), radius: 12, x: 0, y: 6)
                    )
            }
            .accessibilityLabel("Create trip")

            Spacer(minLength: SmartTripSpacing.xs)

            bottomButton(
                title: "Capsules",
                systemImage: selectedPage == .capsules ? "photo.on.rectangle.angled" : "photo.on.rectangle",
                isSelected: selectedPage == .capsules,
                accessibilityLabel: "Journey Capsules",
                action: onCapsules
            )
        }
        .padding(.horizontal, SmartTripSpacing.md)
        .padding(.top, SmartTripSpacing.sm)
        .padding(.bottom, SmartTripSpacing.sm)
        .background(.regularMaterial)
    }

    private func bottomButton(
        title: String,
        systemImage: String,
        isSelected: Bool,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: SmartTripSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))

                Text(title)
                    .font(SmartTripTypography.caption)
            }
            .foregroundStyle(isSelected ? SmartTripColors.primary : SmartTripColors.textSecondary)
            .frame(minWidth: 66, minHeight: 54)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
