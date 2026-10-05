import SwiftUI

struct BulkScheduleView: View {
    private struct Draft: Identifiable {
        let id: UUID
        let place: SavedPlace
        var scheduledDate: Date
        var startTime: Date
        var endTime: Date
        var includesEndTime = false
        var notes: String
        var category: ItineraryCategory = .other
    }

    @Environment(\.dismiss) private var dismiss

    let trip: Trip
    let viewModel: SavedPlaceViewModel
    let onComplete: () -> Void

    @State private var drafts: [Draft]
    @State private var failures: [SavedPlaceViewModel.ScheduleFailure] = []
    @State private var scheduledCount = 0

    init(
        trip: Trip,
        places: [SavedPlace],
        viewModel: SavedPlaceViewModel,
        onComplete: @escaping () -> Void
    ) {
        self.trip = trip
        self.viewModel = viewModel
        self.onComplete = onComplete

        let initialDate = Self.defaultScheduleDate(for: trip)
        _drafts = State(
            initialValue: places.map { place in
                Draft(
                    id: place.id,
                    place: place,
                    scheduledDate: initialDate,
                    startTime: initialDate,
                    endTime: Calendar.current.date(byAdding: .hour, value: 1, to: initialDate) ?? initialDate,
                    notes: place.notes ?? ""
                )
            }
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                    header

                    if scheduledCount > 0 || !failures.isEmpty {
                        resultSummary
                    }

                    VStack(spacing: SmartTripSpacing.md) {
                        ForEach($drafts) { $draft in
                            scheduleCard(for: $draft)
                        }
                    }

                    PrimaryActionButton(primaryButtonTitle, systemImage: "calendar.badge.checkmark") {
                        scheduleSelectedPlaces()
                    }
                    .disabled(drafts.isEmpty)
                    .accessibilityLabel(primaryButtonTitle)
                }
                .padding(SmartTripSpacing.md)
            }
            .background(SmartTripColors.background)
            .navigationTitle("Plan Selected")
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
            Text(trip.name)
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.primary)
                .textCase(.uppercase)

            Text("Plan \(drafts.count) Saved Place\(drafts.count == 1 ? "" : "s")")
                .font(SmartTripTypography.display)
                .foregroundStyle(SmartTripColors.textPrimary)

            Text("Choose schedule details for each place. SmartTrip will add each valid place to the itinerary.")
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
    }

    private var resultSummary: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            if scheduledCount > 0 {
                Label(
                    "\(scheduledCount) activit\(scheduledCount == 1 ? "y" : "ies") scheduled.",
                    systemImage: "checkmark.circle.fill"
                )
                .font(SmartTripTypography.label)
                .foregroundStyle(SmartTripColors.primary)
            }

            ForEach(failures) { failure in
                ErrorBanner(
                    title: "\(failure.placeName) could not be scheduled: \(failure.message)",
                    recoverySuggestion: failure.recoverySuggestion
                )
            }
        }
    }

    private func scheduleCard(
        for draft: Binding<Draft>
    ) -> some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                Text(draft.wrappedValue.place.name)
                    .font(SmartTripTypography.title)
                    .foregroundStyle(SmartTripColors.textPrimary)

                StatusChip(
                    draft.wrappedValue.place.status.displayTitle,
                    systemImage: draft.wrappedValue.place.status.systemImage,
                    style: draft.wrappedValue.place.status.chipStyle
                )
            }

            DatePicker(
                "Date for \(draft.wrappedValue.place.name)",
                selection: draft.scheduledDate,
                displayedComponents: .date
            )

            DatePicker(
                "Start time for \(draft.wrappedValue.place.name)",
                selection: draft.startTime,
                displayedComponents: .hourAndMinute
            )

            Toggle("Add end time", isOn: draft.includesEndTime)

            if draft.wrappedValue.includesEndTime {
                DatePicker(
                    "End time for \(draft.wrappedValue.place.name)",
                    selection: draft.endTime,
                    displayedComponents: .hourAndMinute
                )
            }

            Picker("Category", selection: draft.category) {
                ForEach(ItineraryCategory.allCases, id: \.self) { category in
                    Text(category.rawValue.capitalized)
                        .tag(category)
                }
            }

            TextField("Notes optional", text: draft.notes, axis: .vertical)
                .lineLimit(2...4)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: SmartTripRadius.medium, style: .continuous)
                        .fill(SmartTripColors.surfaceMuted)
                )
        }
        .padding(SmartTripSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
        )
        .accessibilityElement(children: .contain)
    }

    private var primaryButtonTitle: String {
        "Schedule \(drafts.count) Place\(drafts.count == 1 ? "" : "s")"
    }

    private func scheduleSelectedPlaces() {
        let requests = drafts.map { draft in
            SavedPlaceViewModel.ScheduleRequest(
                savedPlaceID: draft.place.id,
                scheduledDate: draft.scheduledDate,
                startTime: combinedDate(draft.scheduledDate, timeFrom: draft.startTime),
                endTime: draft.includesEndTime ? combinedDate(draft.scheduledDate, timeFrom: draft.endTime) : nil,
                notes: draft.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : draft.notes,
                category: draft.category
            )
        }

        let result = viewModel.scheduleSavedPlaces(
            requests,
            tripID: trip.id
        )

        scheduledCount += result.scheduledCount
        failures = result.failures

        if result.isCompleteSuccess {
            onComplete()
            dismiss()
        } else {
            let failedIDs = Set(result.failures.map(\.savedPlaceID))
            drafts.removeAll { !failedIDs.contains($0.id) }
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

    private static func defaultScheduleDate(
        for trip: Trip
    ) -> Date {
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: trip.startDate)
        let end = Calendar.current.startOfDay(for: trip.endDate)

        if today < start {
            return trip.startDate
        }

        if today > end {
            return trip.endDate
        }

        return Date()
    }
}
