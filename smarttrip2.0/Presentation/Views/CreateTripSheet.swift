import SwiftUI

struct CreateTripSheet: View {
    private enum Step: Int, CaseIterable {
        case basics
        case dates
        case review

        var title: String {
            switch self {
            case .basics:
                "Trip Basics"
            case .dates:
                "Trip Dates"
            case .review:
                "Review"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let viewModel: TripViewModel

    @State private var step = Step.basics
    @State private var name = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                    progressHeader

                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(
                            title: errorMessage,
                            recoverySuggestion: viewModel.recoverySuggestion
                        )
                    }

                    stepContent

                    navigationControls
                }
                .padding(SmartTripSpacing.md)
            }
            .background(SmartTripColors.background)
            .navigationTitle("Create Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            Text("Step \(step.rawValue + 1) of \(Step.allCases.count)")
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.primary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                Text(step.title)
                    .font(SmartTripTypography.display)
                    .foregroundStyle(SmartTripColors.textPrimary)

                Text(stepDescription)
                    .font(SmartTripTypography.body)
                    .foregroundStyle(SmartTripColors.textSecondary)
            }

            HStack(spacing: SmartTripSpacing.sm) {
                ForEach(Step.allCases, id: \.rawValue) { item in
                    Capsule()
                        .fill(item.rawValue <= step.rawValue ? SmartTripColors.primary : SmartTripColors.divider)
                        .frame(height: 6)
                }
            }
            .accessibilityHidden(true)
        }
    }

    private var stepDescription: String {
        switch step {
        case .basics:
            "Name the shared workspace and choose the main destination."
        case .dates:
            "Set the travel window your group will plan around."
        case .review:
            "Check the details before creating your trip."
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .basics:
            card {
                VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
                    TextField("Trip name", text: $name)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                        .padding()
                        .background(fieldBackground)
                        .accessibilityLabel("Trip name")

                    TextField("Destination", text: $destination)
                        .textContentType(.addressCity)
                        .textInputAutocapitalization(.words)
                        .padding()
                        .background(fieldBackground)
                        .accessibilityLabel("Destination")
                }
            }

        case .dates:
            card {
                VStack(spacing: SmartTripSpacing.md) {
                    DatePicker(
                        "Start date",
                        selection: $startDate,
                        displayedComponents: .date
                    )

                    Divider()

                    DatePicker(
                        "End date",
                        selection: $endDate,
                        displayedComponents: .date
                    )
                }
            }

        case .review:
            card {
                VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
                    reviewRow("Trip", value: name.isEmpty ? "Not entered" : name)
                    reviewRow("Destination", value: destination.isEmpty ? "Not entered" : destination)
                    reviewRow("Dates", value: "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))")
                }
            }
        }
    }

    private var navigationControls: some View {
        VStack(spacing: SmartTripSpacing.sm) {
            if step == .review {
                PrimaryActionButton("Create Trip", systemImage: "checkmark") {
                    createTrip()
                }
            } else {
                PrimaryActionButton("Continue", systemImage: "arrow.right") {
                    goForward()
                }
            }

            if step != .basics {
                SecondaryActionButton("Back", systemImage: "chevron.left", isFullWidth: true) {
                    goBack()
                }
            }
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: SmartTripRadius.medium, style: .continuous)
            .fill(SmartTripColors.surface)
            .shadow(color: SmartTripColors.primary.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func card<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(SmartTripSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                    .fill(SmartTripColors.surface)
                    .shadow(color: SmartTripColors.primary.opacity(0.06), radius: 14, x: 0, y: 6)
            )
    }

    private func reviewRow(
        _ title: String,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
            Text(title)
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.textSecondary)
                .textCase(.uppercase)

            Text(value)
                .font(SmartTripTypography.headline)
                .foregroundStyle(SmartTripColors.textPrimary)
        }
    }

    private func goForward() {
        switch step {
        case .basics:
            step = .dates
        case .dates:
            step = .review
        case .review:
            break
        }
    }

    private func goBack() {
        switch step {
        case .basics:
            break
        case .dates:
            step = .basics
        case .review:
            step = .dates
        }
    }

    private func createTrip() {
        let createdTrip = viewModel.createTrip(
            name: name,
            destination: destination,
            startDate: startDate,
            endDate: endDate
        )

        if createdTrip != nil {
            dismiss()
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
