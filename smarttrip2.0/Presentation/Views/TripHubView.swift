import SwiftUI

struct TripHubView: View {
    let trip: Trip

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                TripCard(trip: trip)

                EmptyStateView(
                    systemImage: "square.grid.2x2",
                    title: "Trip Hub is next",
                    message: "This placeholder confirms trip navigation. The full hub, Saved Places, Itinerary, and Journey Capsule sections will be added in the next Phase 4 steps."
                )
            }
            .padding(SmartTripSpacing.md)
        }
        .background(SmartTripColors.background.ignoresSafeArea())
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
