import SwiftUI

struct AddPlaceSheet: View {
    @Environment(\.dismiss) private var dismiss

    let trip: Trip
    let viewModel: SavedPlaceViewModel

    @State private var name = ""
    @State private var urlString = ""
    @State private var notes = ""
    @State private var localError: String?
    @State private var placeAutocomplete = MapKitPlaceAutocompleteService()
    @State private var isSelectingPlaceSuggestion = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                    VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
                        Text("Add Place")
                            .font(SmartTripTypography.display)
                            .foregroundStyle(SmartTripColors.textPrimary)

                        Text("Save an idea for \(trip.name) so it can be reviewed and scheduled later.")
                            .font(SmartTripTypography.body)
                            .foregroundStyle(SmartTripColors.textSecondary)
                    }

                    if let localError {
                        ErrorBanner(title: localError)
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(
                            title: errorMessage,
                            recoverySuggestion: viewModel.recoverySuggestion
                        )
                    }

                    VStack(spacing: SmartTripSpacing.md) {
                        TextField("Place name", text: $name)
                            .textInputAutocapitalization(.words)
                            .padding()
                            .background(fieldBackground)
                            .accessibilityLabel("Place name")

                        suggestionList(
                            suggestions: placeAutocomplete.suggestions,
                            selectionAction: selectPlaceSuggestion
                        )

                        TextField("URL optional", text: $urlString)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .padding()
                            .background(fieldBackground)
                            .accessibilityLabel("Place URL")

                        TextField("Notes optional", text: $notes, axis: .vertical)
                            .lineLimit(3...5)
                            .padding()
                            .background(fieldBackground)
                            .accessibilityLabel("Place notes")
                    }

                    PrimaryActionButton("Save Place", systemImage: "bookmark") {
                        addPlace()
                    }
                }
                .padding(SmartTripSpacing.md)
            }
            .background(SmartTripColors.background)
            .navigationTitle("Add Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.clearPresentationError()
                        placeAutocomplete.clearSuggestions()
                        dismiss()
                    }
                }
            }
            .onChange(of: name) { _, newValue in
                if isSelectingPlaceSuggestion {
                    isSelectingPlaceSuggestion = false
                    placeAutocomplete.clearSuggestions()
                } else {
                    placeAutocomplete.updateQuery(newValue)
                }
            }
            .onDisappear {
                placeAutocomplete.clearSuggestions()
            }
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: SmartTripRadius.medium, style: .continuous)
            .fill(SmartTripColors.surface)
    }

    private func addPlace() {
        localError = nil

        let url = parsedURL()

        if !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, url == nil {
            localError = "Enter a valid URL or leave it blank."
            return
        }

        let savedPlace = viewModel.capturePlace(
            tripID: trip.id,
            name: name,
            url: url,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
        )

        if savedPlace != nil {
            placeAutocomplete.clearSuggestions()
            dismiss()
        }
    }

    @ViewBuilder
    private func suggestionList(
        suggestions: [PlaceSuggestion],
        selectionAction: @escaping (PlaceSuggestion) -> Void
    ) -> some View {
        if !suggestions.isEmpty {
            VStack(spacing: 0) {
                ForEach(suggestions) { suggestion in
                    Button {
                        selectionAction(suggestion)
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
                        .padding(.horizontal, SmartTripSpacing.md)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(accessibilityLabel(for: suggestion))

                    if suggestion.id != suggestions.last?.id {
                        Divider()
                            .padding(.leading, SmartTripSpacing.md)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: SmartTripRadius.medium, style: .continuous)
                    .fill(SmartTripColors.surface)
                    .shadow(color: SmartTripColors.primary.opacity(0.06), radius: 10, x: 0, y: 4)
            )
        }
    }

    private func selectPlaceSuggestion(
        _ suggestion: PlaceSuggestion
    ) {
        isSelectingPlaceSuggestion = true
        name = displayValue(for: suggestion)
        placeAutocomplete.clearSuggestions()
    }

    private func displayValue(
        for suggestion: PlaceSuggestion
    ) -> String {
        guard !suggestion.subtitle.isEmpty else {
            return suggestion.title
        }

        return "\(suggestion.title), \(suggestion.subtitle)"
    }

    private func accessibilityLabel(
        for suggestion: PlaceSuggestion
    ) -> String {
        displayValue(for: suggestion)
    }

    private func parsedURL() -> URL? {
        let trimmedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedURL.isEmpty else {
            return nil
        }

        return URL(string: trimmedURL)
    }
}
