import SwiftUI

struct SchedulePlaceSheet: View {
    @Environment(\.dismiss) private var dismiss

    let trip: Trip
    let place: SavedPlace
    let viewModel: SavedPlaceViewModel
    let onScheduled: () -> Void

    @State private var scheduledDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var includesEndTime = false
    @State private var notes: String
    @State private var category: ItineraryCategory = .other

    init(
        trip: Trip,
        place: SavedPlace,
        viewModel: SavedPlaceViewModel,
        onScheduled: @escaping () -> Void
    ) {
        self.trip = trip
        self.place = place
        self.viewModel = viewModel
        self.onScheduled = onScheduled

        let initialDate = Self.clamped(
            Date(),
            lowerBound: trip.startDate,
            upperBound: trip.endDate
        )
        _scheduledDate = State(initialValue: initialDate)
        _startTime = State(initialValue: initialDate)
        _endTime = State(initialValue: Calendar.current.date(byAdding: .hour, value: 1, to: initialDate) ?? initialDate)
        _notes = State(initialValue: place.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                    header

                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(
                            title: errorMessage,
                            recoverySuggestion: viewModel.recoverySuggestion
                        )
                    }

                    scheduleForm

                    PrimaryActionButton("Schedule Place", systemImage: "calendar.badge.checkmark") {
                        schedulePlace()
                    }
                    .accessibilityLabel("Schedule \(place.name)")
                }
                .padding(SmartTripSpacing.md)
            }
            .background(SmartTripColors.background)
            .navigationTitle("Schedule Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.clearPresentationError()
                        dismiss()
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
            StatusChip(
                place.status.displayTitle,
                systemImage: place.status.systemImage,
                style: place.status.chipStyle
            )

            Text(place.name)
                .font(SmartTripTypography.display)
                .foregroundStyle(SmartTripColors.textPrimary)

            Text("Commit this saved place to \(trip.name)'s itinerary.")
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
    }

    private var scheduleForm: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            DatePicker(
                "Date",
                selection: $scheduledDate,
                in: trip.startDate...trip.endDate,
                displayedComponents: .date
            )

            Divider()

            DatePicker(
                "Start time",
                selection: $startTime,
                displayedComponents: .hourAndMinute
            )

            Toggle("Add end time", isOn: $includesEndTime)

            if includesEndTime {
                DatePicker(
                    "End time",
                    selection: $endTime,
                    displayedComponents: .hourAndMinute
                )
            }

            Divider()

            Picker("Category", selection: $category) {
                ForEach(ItineraryCategory.allCases, id: \.self) { category in
                    Text(category.rawValue.capitalized)
                        .tag(category)
                }
            }

            TextField("Notes optional", text: $notes, axis: .vertical)
                .lineLimit(3...5)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: SmartTripRadius.medium, style: .continuous)
                        .fill(SmartTripColors.surfaceMuted)
                )
        }
        .padding(SmartTripSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
        )
    }

    private func schedulePlace() {
        let item = viewModel.scheduleSavedPlace(
            savedPlaceID: place.id,
            tripID: trip.id,
            scheduledDate: scheduledDate,
            startTime: combinedDate(
                scheduledDate,
                timeFrom: startTime
            ),
            endTime: includesEndTime ? combinedDate(scheduledDate, timeFrom: endTime) : nil,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes,
            category: category
        )

        if item != nil {
            onScheduled()
            dismiss()
        }
    }

    private func combinedDate(
        _ date: Date,
        timeFrom time: Date
    ) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        var components = DateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        return calendar.date(from: components) ?? date
    }

    private static func clamped(
        _ date: Date,
        lowerBound: Date,
        upperBound: Date
    ) -> Date {
        min(max(date, lowerBound), upperBound)
    }
}
