import SwiftUI

struct JourneyCapsuleView: View {
    let trip: Trip

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                header

                capsulePreview

                EmptyStateView(
                    systemImage: "photo.stack",
                    title: "No memories yet",
                    message: "Your Journey Capsule will collect moments from this trip as you add them."
                )
            }
            .padding(SmartTripSpacing.md)
        }
        .background(SmartTripColors.background.ignoresSafeArea())
        .navigationTitle("Journey Capsule")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
            Text(trip.destination)
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.primary)
                .textCase(.uppercase)

            Text("Journey Capsule")
                .font(SmartTripTypography.display)
                .foregroundStyle(SmartTripColors.textPrimary)

            Text("A simple place to revisit memories from \(trip.name).")
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var capsulePreview: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [
                        SmartTripColors.deepBrown,
                        SmartTripColors.warmAccent,
                        SmartTripColors.highlight.opacity(0.74)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 210)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "camera.aperture")
                        .font(.system(size: 72, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.18))
                        .padding(SmartTripSpacing.lg)
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
                    StatusChip("Trip memories", systemImage: "sparkles", style: .shortlisted)

                    Text(trip.name)
                        .font(SmartTripTypography.title)
                        .foregroundStyle(.white)

                    Label(dateRangeText, systemImage: "calendar")
                        .font(SmartTripTypography.body)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(SmartTripSpacing.lg)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: SmartTripRadius.extraLarge, style: .continuous)
            )
            .shadow(color: SmartTripColors.warmAccent.opacity(0.18), radius: 18, x: 0, y: 10)

            Text("Memory persistence is not connected yet, so this production screen intentionally shows an empty capsule instead of demo memories.")
                .font(SmartTripTypography.caption)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
    }

    private var dateRangeText: String {
        "\(Self.dateFormatter.string(from: trip.startDate)) - \(Self.dateFormatter.string(from: trip.endDate))"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

#Preview("Journey Capsule") {
    NavigationStack {
        JourneyCapsuleView(
            trip: Trip(
                name: "Tokyo Trip",
                destination: "Tokyo",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
            )
        )
    }
}
