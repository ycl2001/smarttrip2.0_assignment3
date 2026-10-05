import SwiftUI

struct CreateTripSheet: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: TripViewModel

    @State private var name = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                    TextField("Trip name", text: $name)
                        .textContentType(.name)

                    TextField("Destination", text: $destination)
                        .textContentType(.addressCity)
                }

                Section("Dates") {
                    DatePicker(
                        "Start date",
                        selection: $startDate,
                        displayedComponents: .date
                    )

                    DatePicker(
                        "End date",
                        selection: $endDate,
                        displayedComponents: .date
                    )
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        ErrorBanner(
                            title: errorMessage,
                            recoverySuggestion: viewModel.recoverySuggestion
                        )
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(SmartTripColors.background)
            .navigationTitle("Create Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createTrip()
                    }
                }
            }
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
}
