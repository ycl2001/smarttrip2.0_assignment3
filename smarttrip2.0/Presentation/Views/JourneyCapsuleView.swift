import SwiftUI

struct JourneyCapsuleView: View {
    let trip: Trip
    @State private var viewModel: JourneyCapsuleViewModel
    @State private var isShowingCaptureMoment = false

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
                viewModel: viewModel
            )
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

                SecondaryActionButton("Capture a Moment") {
                    viewModel.clearPresentationError()
                    isShowingCaptureMoment = true
                }
            }
        }
        .accessibilityElement(children: .combine)
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

                Button {
                    viewModel.clearPresentationError()
                    isShowingCaptureMoment = true
                } label: {
                    captureTile
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Capture a Moment")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: SmartTripSpacing.md) {
            EmptyStateView(
                systemImage: "photo.stack",
                title: "Your Journey Capsule is empty",
                message: "Capture the places, thoughts, and moments you want to remember from this trip."
            )

            PrimaryActionButton("Capture a Moment") {
                viewModel.clearPresentationError()
                isShowingCaptureMoment = true
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SmartTripSpacing.lg)
    }

    private var captureTile: some View {
        VStack(spacing: SmartTripSpacing.md) {
            Image(systemName: "plus")
                .font(.title.weight(.semibold))
                .foregroundStyle(SmartTripColors.primary)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(SmartTripColors.primary.opacity(0.12))
                )

            Text("Capture")
                .font(SmartTripTypography.headline)
                .foregroundStyle(SmartTripColors.textPrimary)

            Text("Add a fresh moment")
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 230)
        .padding(SmartTripSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
                .foregroundStyle(SmartTripColors.divider)
        )
    }

    private var memoryCountText: String {
        switch viewModel.memories.count {
        case 1:
            "1 memory"
        default:
            "\(viewModel.memories.count) memories"
        }
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
    @State var viewModel: JourneyCapsuleViewModel
    @State private var location = ""
    @State private var caption = ""
    @State private var capturedAt = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place or location", text: $location)
                        .textInputAutocapitalization(.words)
                        .accessibilityLabel("Where were you?")

                    TextEditor(text: $caption)
                        .frame(minHeight: 112)
                        .accessibilityLabel("What do you want to remember?")
                } header: {
                    Text("Moment")
                } footer: {
                    Text("Photo capture is deferred until SmartTrip has a dedicated image storage flow.")
                }

                Section("Date") {
                    DatePicker(
                        "Captured at",
                        selection: $capturedAt,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        ErrorBanner(
                            title: errorMessage,
                            recoverySuggestion: viewModel.recoverySuggestion
                        )
                    }
                }
            }
            .navigationTitle("Capture a Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.clearPresentationError()
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
        }
    }

    private func save() {
        guard viewModel.captureMoment(
            location: location,
            caption: caption,
            capturedAt: capturedAt
        ) != nil else {
            return
        }

        dismiss()
    }
}
