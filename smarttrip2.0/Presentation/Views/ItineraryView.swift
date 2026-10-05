import SwiftUI

struct ItineraryView: View {
    let trip: Trip
    @State private var viewModel: ItineraryViewModel

    init(
        trip: Trip,
        viewModel: ItineraryViewModel
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

                content
            }
            .padding(SmartTripSpacing.md)
        }
        .background(SmartTripColors.background.ignoresSafeArea())
        .navigationTitle("Itinerary")
        .onAppear {
            viewModel.load()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
            Text(trip.name)
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.primary)
                .textCase(.uppercase)

            Text("Itinerary")
                .font(SmartTripTypography.display)
                .foregroundStyle(SmartTripColors.textPrimary)

            Text("Confirmed activities for this trip, grouped by day.")
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading itinerary")
                .frame(maxWidth: .infinity, minHeight: 180)
        } else if viewModel.items.isEmpty {
            EmptyStateView(
                systemImage: "calendar.badge.clock",
                title: "Nothing scheduled yet",
                message: "Schedule a saved place or add an activity later to start building your itinerary."
            )
        } else {
            VStack(alignment: .leading, spacing: SmartTripSpacing.xl) {
                ForEach(groupedDays, id: \.date) { day in
                    VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
                        SectionHeader(
                            dayTitle(for: day.date),
                            subtitle: dateFormatter.string(from: day.date)
                        )

                        ForEach(day.items) { item in
                            ItineraryCard(item: item)
                        }
                    }
                }
            }
        }
    }

    private var groupedDays: [(date: Date, items: [ItineraryItem])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: viewModel.items) { item in
            calendar.startOfDay(for: item.date)
        }

        return groups
            .map { date, items in
                (
                    date: date,
                    items: items.sorted {
                        ($0.startTime ?? $0.date) < ($1.startTime ?? $1.date)
                    }
                )
            }
            .sorted { $0.date < $1.date }
    }

    private func dayTitle(
        for date: Date
    ) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: trip.startDate)
        let current = calendar.startOfDay(for: date)
        let dayNumber = (calendar.dateComponents([.day], from: start, to: current).day ?? 0) + 1

        return "Day \(max(dayNumber, 1))"
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
