import SwiftUI

struct JourneyCapsuleView: View {
    let trip: Trip
    @State private var viewModel: JourneyCapsuleViewModel
    @State private var isShowingCaptureMoment = false
    @State private var isShowingReminderSheet = false
    @State private var reminderDate = Date().addingTimeInterval(60 * 60)

    init(
        trip: Trip,
        viewModel: JourneyCapsuleViewModel
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
        .navigationTitle("Journey Capsule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.clearPresentationError()
                    isShowingCaptureMoment = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Capture a Moment")
            }
        }
        .sheet(isPresented: $isShowingCaptureMoment) {
            CaptureMomentView(
                trip: trip,
                journeyCapsuleViewModel: viewModel,
                viewModel: viewModel.makeCaptureMomentViewModel()
            )
        }
        .sheet(isPresented: $isShowingReminderSheet) {
            reminderSheet
        }
        .alert(
            "Journey Capsule reminder",
            isPresented: reminderMessageIsPresented
        ) {
            Button("OK") {
                viewModel.clearReminderMessage()
            }
        } message: {
            Text(viewModel.reminderMessage ?? "")
        }
        .onAppear {
            viewModel.loadMemories()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                Text(trip.destination)
                    .font(SmartTripTypography.caption)
                    .foregroundStyle(SmartTripColors.primary)
                    .textCase(.uppercase)

                Text(trip.name)
                    .font(SmartTripTypography.display)
                    .foregroundStyle(SmartTripColors.textPrimary)

                Text(dateRangeText)
                    .font(SmartTripTypography.body)
                    .foregroundStyle(SmartTripColors.textSecondary)
            }

            HStack(spacing: SmartTripSpacing.sm) {
                StatusChip(memoryCountText, systemImage: "photo.stack", style: .shortlisted)

                Spacer()

                Button {
                    viewModel.clearReminderMessage()
                    reminderDate = Date().addingTimeInterval(60 * 60)
                    isShowingReminderSheet = true
                } label: {
                    Image(systemName: "bell")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(SmartTripColors.primary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(SmartTripColors.surface)
                        )
                        .overlay(
                            Circle()
                                .stroke(SmartTripColors.primary.opacity(0.22))
                        )
                }
                .accessibilityLabel("Set Journey Capsule reminder")
            }
        }
    }

    private var reminderSheet: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Date and time",
                        selection: $reminderDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                } footer: {
                    Text("We'll remind you to capture a moment from \(trip.name).")
                }
            }
            .navigationTitle("Remind me to capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowingReminderSheet = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Set Reminder") {
                        Task {
                            let didSchedule = await viewModel.scheduleReminder(
                                for: trip,
                                at: reminderDate
                            )
                            isShowingReminderSheet = false

                            if !didSchedule {
                                return
                            }
                        }
                    }
                    .disabled(viewModel.isSchedulingReminder)
                }
            }
        }
        .interactiveDismissDisabled(viewModel.isSchedulingReminder)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading Journey Capsule...")
                .frame(maxWidth: .infinity, minHeight: 180)
        } else if viewModel.memories.isEmpty {
            emptyState
        } else {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: SmartTripSpacing.md),
                    GridItem(.flexible(), spacing: SmartTripSpacing.md)
                ],
                spacing: SmartTripSpacing.lg
            ) {
                ForEach(viewModel.memories) { memory in
                    NavigationLink {
                        JourneyMemoryDetailView(
                            trip: trip,
                            memory: memory
                        )
                    } label: {
                        JourneyMemoryPostcard(
                            trip: trip,
                            memory: memory
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(memoryAccessibilityLabel(for: memory))
                }

            }
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            systemImage: "photo.stack",
            title: "No memories yet",
            message: "Capture the places, thoughts, and moments you want to remember from this trip."
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, SmartTripSpacing.lg)
    }

    private var memoryCountText: String {
        switch viewModel.memories.count {
        case 1:
            "1 memory"
        default:
            "\(viewModel.memories.count) memories"
        }
    }

    private var reminderMessageIsPresented: Binding<Bool> {
        Binding(
            get: { viewModel.reminderMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearReminderMessage()
                }
            }
        )
    }

    private var dateRangeText: String {
        "\(Self.dateFormatter.string(from: trip.startDate)) - \(Self.dateFormatter.string(from: trip.endDate))"
    }

    private func memoryAccessibilityLabel(
        for memory: TripMemory
    ) -> String {
        let location = memory.location ?? trip.destination
        return "Open memory from \(location), captured \(Self.dateFormatter.string(from: memory.createdAt))"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

private struct JourneyMemoryPostcard: View {
    let trip: Trip
    let memory: TripMemory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            photoArea
                .frame(height: 124)
                .frame(maxWidth: .infinity)
                .clipped()

            VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
                HStack(alignment: .firstTextBaseline) {
                    Text(memory.location ?? trip.destination)
                        .font(SmartTripTypography.headline)
                        .foregroundStyle(SmartTripColors.textPrimary)
                        .lineLimit(2)

                    Spacer(minLength: SmartTripSpacing.sm)

                    Text(Self.dayFormatter.string(from: memory.createdAt))
                        .font(SmartTripTypography.caption)
                        .foregroundStyle(SmartTripColors.textSecondary)
                        .lineLimit(1)
                }

                if let caption = memory.caption {
                    Text(caption)
                        .font(SmartTripTypography.body)
                        .foregroundStyle(SmartTripColors.textSecondary)
                        .lineLimit(3)
                }

                HStack(spacing: SmartTripSpacing.xs) {
                    Image(systemName: "paperplane")
                        .font(.caption.weight(.semibold))

                    Text(trip.destination)
                        .font(SmartTripTypography.caption)
                }
                .foregroundStyle(SmartTripColors.primary)
            }
            .padding(SmartTripSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(SmartTripColors.surface)
        .clipShape(
            RoundedRectangle(cornerRadius: SmartTripRadius.medium, style: .continuous)
        )
        .overlay(alignment: .topTrailing) {
            postcardMark
                .padding(SmartTripSpacing.sm)
        }
        .shadow(color: SmartTripColors.primary.opacity(0.08), radius: 14, x: 0, y: 8)
    }

    @ViewBuilder
    private var photoArea: some View {
        if let photoIdentifier = memory.photoIdentifier {
            Image(photoIdentifier)
                .resizable()
                .scaledToFill()
                .overlay(.black.opacity(0.16))
        } else {
            LinearGradient(
                colors: [
                    SmartTripColors.primary,
                    SmartTripColors.accent,
                    SmartTripColors.highlight.opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                    Text(trip.destination.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.82))

                    Text(memory.location ?? "Journey Memory")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                .padding(SmartTripSpacing.md)
            }
        }
    }

    private var postcardMark: some View {
        Text("CAPTURED")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, SmartTripSpacing.sm)
            .padding(.vertical, SmartTripSpacing.xs)
            .background(
                Capsule()
                    .fill(.black.opacity(0.22))
            )
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }()
}

private struct JourneyMemoryDetailView: View {
    let trip: Trip
    let memory: TripMemory

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                JourneyMemoryPostcard(
                    trip: trip,
                    memory: memory
                )

                VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
                    Text(memory.location ?? trip.destination)
                        .font(SmartTripTypography.display)
                        .foregroundStyle(SmartTripColors.textPrimary)

                    Label(Self.dateFormatter.string(from: memory.createdAt), systemImage: "calendar")
                        .font(SmartTripTypography.body)
                        .foregroundStyle(SmartTripColors.textSecondary)

                    if let caption = memory.caption {
                        Text(caption)
                            .font(SmartTripTypography.body)
                            .foregroundStyle(SmartTripColors.textPrimary)
                    }

                    Text(trip.name)
                        .font(SmartTripTypography.caption)
                        .foregroundStyle(SmartTripColors.primary)
                        .textCase(.uppercase)
                }
            }
            .padding(SmartTripSpacing.md)
        }
        .background(SmartTripColors.background.ignoresSafeArea())
        .navigationTitle("Memory")
        .navigationBarTitleDisplayMode(.inline)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }()
}

private struct CaptureMomentView: View {
    @Environment(\.dismiss) private var dismiss

    let trip: Trip
    let journeyCapsuleViewModel: JourneyCapsuleViewModel
    @State private var viewModel: CaptureMomentViewModel

    init(
        trip: Trip,
        journeyCapsuleViewModel: JourneyCapsuleViewModel,
        viewModel: CaptureMomentViewModel
    ) {
        self.trip = trip
        self.journeyCapsuleViewModel = journeyCapsuleViewModel
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                    tripContext

                    Text("What do you want to remember?")
                        .font(SmartTripTypography.title)
                        .foregroundStyle(SmartTripColors.textPrimary)

                    captureCard

                    capturedMetadata

                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(
                            title: errorMessage,
                            recoverySuggestion: viewModel.recoverySuggestion
                        )
                    }
                }
                .padding(SmartTripSpacing.md)
            }
            .background(SmartTripColors.background.ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Capture a Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.clearPresentationError()
                        viewModel.clearLocationSuggestions()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .onDisappear {
                viewModel.clearLocationSuggestions()
            }
        }
    }

    private var tripContext: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
            Text(trip.destination)
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.primary)
                .textCase(.uppercase)

            Text(tripDayAndDateText)
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
    }

    private var captureCard: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            HStack(spacing: SmartTripSpacing.sm) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(SmartTripColors.primary)
                    .accessibilityHidden(true)

                TextField("Place or location", text: locationBinding)
                    .textFieldStyle(.plain)
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("Where were you?")
            }

            if !viewModel.locationSuggestions.isEmpty {
                locationSuggestionList
            }

            Divider()

            Text("What made today memorable?")
                .font(SmartTripTypography.headline)
                .foregroundStyle(SmartTripColors.textPrimary)

            TextEditor(text: $viewModel.caption)
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 124)
                .accessibilityLabel("What do you want to remember?")
        }
        .padding(SmartTripSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
        )
    }

    private var capturedMetadata: some View {
        DatePicker(
            selection: $viewModel.capturedAt,
            displayedComponents: [.date, .hourAndMinute]
        ) {
            VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                Text("Captured")
                    .font(SmartTripTypography.caption)
                    .foregroundStyle(SmartTripColors.textSecondary)

                Text(viewModel.capturedAt, format: .dateTime.day().month(.abbreviated).year().hour().minute())
                    .font(SmartTripTypography.body)
                    .foregroundStyle(SmartTripColors.textPrimary)
            }
        }
        .datePickerStyle(.compact)
        .padding(SmartTripSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.medium, style: .continuous)
                .fill(SmartTripColors.surface)
        )
    }

    private var tripDayAndDateText: String {
        let calendar = Calendar.current
        let tripStart = calendar.startOfDay(for: trip.startDate)
        let tripEnd = calendar.startOfDay(for: trip.endDate)
        let capturedDay = calendar.startOfDay(for: viewModel.capturedAt)
        let dateText = viewModel.capturedAt.formatted(.dateTime.day().month(.abbreviated).year())

        guard capturedDay >= tripStart, capturedDay <= tripEnd else {
            return dateText
        }

        let day = (calendar.dateComponents([.day], from: tripStart, to: capturedDay).day ?? 0) + 1
        return "Day \(day) · \(dateText)"
    }

    private func save() {
        guard viewModel.save(tripID: trip.id) != nil else {
            return
        }

        journeyCapsuleViewModel.loadMemories()
        viewModel.clearLocationSuggestions()
        dismiss()
    }

    private var locationBinding: Binding<String> {
        Binding(
            get: { viewModel.locationText },
            set: { viewModel.updateLocationText($0) }
        )
    }

    private var locationSuggestionList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.locationSuggestions) { suggestion in
                Button {
                    viewModel.selectLocationSuggestion(suggestion)
                } label: {
                    VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                        Text(suggestion.title)
                            .font(SmartTripTypography.body)
                            .foregroundStyle(SmartTripColors.textPrimary)

                        if !suggestion.subtitle.isEmpty {
                            Text(suggestion.subtitle)
                                .font(SmartTripTypography.caption)
                                .foregroundStyle(SmartTripColors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, SmartTripSpacing.sm)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(suggestionAccessibilityLabel(for: suggestion))

                if suggestion.id != viewModel.locationSuggestions.last?.id {
                    Divider()
                }
            }
        }
        .padding(.horizontal, SmartTripSpacing.xs)
        .background(SmartTripColors.background)
        .clipShape(RoundedRectangle(cornerRadius: SmartTripRadius.medium, style: .continuous))
    }

    private func suggestionAccessibilityLabel(
        for suggestion: PlaceSuggestion
    ) -> String {
        guard !suggestion.subtitle.isEmpty else {
            return suggestion.title
        }

        return "\(suggestion.title), \(suggestion.subtitle)"
    }
}
