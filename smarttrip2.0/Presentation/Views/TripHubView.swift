import SwiftUI

struct TripHubView: View {
    @Environment(\.smartTripDependencies) private var dependencies

    let trip: Trip
    let viewModel: TripHubViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SmartTripSpacing.lg) {
                heroHeader

                if let errorMessage = viewModel?.errorMessage {
                    ErrorBanner(
                        title: errorMessage,
                        recoverySuggestion: viewModel?.recoverySuggestion
                    )
                }

                nextUpSection

                planSection

                tripSection
            }
            .padding(SmartTripSpacing.md)
        }
        .background(SmartTripColors.background.ignoresSafeArea())
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel?.load()
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            ZStack(alignment: .bottomLeading) {
                cover

                VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
                    StatusChip(dateContext, systemImage: "calendar", style: .idea)

                    VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                        Text(trip.destination)
                            .font(SmartTripTypography.caption)
                            .foregroundStyle(.white.opacity(0.86))
                            .textCase(.uppercase)

                        Text(trip.name)
                            .font(SmartTripTypography.display)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }

                    Label(dateRangeText, systemImage: "calendar")
                        .font(SmartTripTypography.body)
                        .foregroundStyle(.white.opacity(0.92))
                }
                .padding(SmartTripSpacing.lg)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: SmartTripRadius.extraLarge, style: .continuous)
            )
            .shadow(color: SmartTripColors.primary.opacity(0.14), radius: 18, x: 0, y: 10)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var cover: some View {
        if let coverImageName = trip.coverImageName {
            Image(coverImageName)
                .resizable()
                .scaledToFill()
                .frame(height: 260)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(.black.opacity(0.34))
                .accessibilityHidden(true)
        } else {
            LinearGradient(
                colors: [
                    SmartTripColors.primary,
                    SmartTripColors.accent,
                    SmartTripColors.warmAccent.opacity(0.86)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 260)
            .overlay(alignment: .topTrailing) {
                Image(systemName: "globe.asia.australia.fill")
                    .font(.system(size: 76, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.18))
                    .padding(SmartTripSpacing.lg)
                    .accessibilityHidden(true)
            }
        }
    }

    private var nextUpSection: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            SectionHeader("Next Up", subtitle: "Your upcoming itinerary")

            if viewModel?.isLoading == true {
                ProgressView("Loading trip details")
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if let nextItem = viewModel?.upcomingItems.first {
                upcomingCard(nextItem)
            } else {
                EmptyStateView(
                    systemImage: "calendar.badge.clock",
                    title: "Nothing scheduled yet",
                    message: "Schedule a saved place later to start building this trip's itinerary."
                )
            }
        }
    }

    private func upcomingCard(
        _ item: ItineraryItem
    ) -> some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.sm) {
            StatusChip(item.category.rawValue.capitalized, systemImage: "clock", style: .scheduled)

            Text(item.title)
                .font(SmartTripTypography.title)
                .foregroundStyle(SmartTripColors.textPrimary)

            Label(item.location, systemImage: "location")
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)

            Label(upcomingTimeText(for: item), systemImage: "calendar")
                .font(SmartTripTypography.body)
                .foregroundStyle(SmartTripColors.textSecondary)
        }
        .padding(SmartTripSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
                .shadow(color: SmartTripColors.primary.opacity(0.06), radius: 14, x: 0, y: 6)
        )
    }

    private var planSection: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            SectionHeader("Plan Your Trip", subtitle: "Keep ideas and confirmed plans connected")

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: SmartTripSpacing.md
            ) {
                if let dependencies {
                    NavigationLink {
                        SavedPlacesView(
                            trip: trip,
                            viewModel: dependencies.makeSavedPlaceViewModel()
                        )
                    } label: {
                        hubDestinationCardContent(
                            title: "Saved Places",
                            subtitle: savedPlacesSummary,
                            systemImage: "bookmark.fill",
                            tint: SmartTripColors.primary
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Saved Places. \(savedPlacesSummary)")
                } else {
                    hubDestinationCard(
                        title: "Saved Places",
                        subtitle: savedPlacesSummary,
                        systemImage: "bookmark.fill",
                        tint: SmartTripColors.primary
                    )
                }

                hubDestinationCard(
                    title: "Itinerary",
                    subtitle: itinerarySummary,
                    systemImage: "calendar.badge.checkmark",
                    tint: SmartTripColors.accent
                )
            }
        }
    }

    private var tripSection: some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            SectionHeader("Your Trip", subtitle: "People and memories")

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: SmartTripSpacing.md
            ) {
                hubDestinationCard(
                    title: "Members",
                    subtitle: "Manage travellers later",
                    systemImage: "person.2.fill",
                    tint: SmartTripColors.warmAccent
                )

                hubDestinationCard(
                    title: "Journey Capsule",
                    subtitle: "Memories coming soon",
                    systemImage: "photo.on.rectangle.angled",
                    tint: SmartTripColors.highlight
                )
            }
        }
    }

    private func hubDestinationCard(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color
    ) -> some View {
        NavigationLink {
            HubPlaceholderView(
                title: title,
                message: "\(title) will be implemented in the next Phase 4 workflow steps."
            )
        } label: {
            VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(tint.opacity(0.14))
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                    Text(title)
                        .font(SmartTripTypography.headline)
                        .foregroundStyle(SmartTripColors.textPrimary)

                    Text(subtitle)
                        .font(SmartTripTypography.caption)
                        .foregroundStyle(SmartTripColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
            .padding(SmartTripSpacing.md)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                    .fill(SmartTripColors.surface)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title). \(subtitle)")
    }

    private func hubDestinationCardContent(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: SmartTripSpacing.md) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(tint.opacity(0.14))
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SmartTripSpacing.xs) {
                Text(title)
                    .font(SmartTripTypography.headline)
                    .foregroundStyle(SmartTripColors.textPrimary)

                Text(subtitle)
                    .font(SmartTripTypography.caption)
                    .foregroundStyle(SmartTripColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(SmartTripSpacing.md)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: SmartTripRadius.large, style: .continuous)
                .fill(SmartTripColors.surface)
        )
    }

    private var savedPlacesSummary: String {
        guard let count = viewModel?.savedPlaceCount else {
            return "Open saved ideas"
        }

        return "\(count) saved place\(count == 1 ? "" : "s")"
    }

    private var itinerarySummary: String {
        guard let count = viewModel?.itineraryItemCount else {
            return "Open confirmed plans"
        }

        return "\(count) scheduled item\(count == 1 ? "" : "s")"
    }

    private var dateContext: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: trip.startDate)
        let end = calendar.startOfDay(for: trip.endDate)

        if today < start {
            let days = calendar.dateComponents([.day], from: today, to: start).day ?? 0
            return "Starts in \(days) day\(days == 1 ? "" : "s")"
        }

        if today > end {
            return "Completed"
        }

        let currentDay = (calendar.dateComponents([.day], from: start, to: today).day ?? 0) + 1
        let totalDays = (calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1
        return "Day \(currentDay) of \(totalDays)"
    }

    private var dateRangeText: String {
        "\(dateFormatter.string(from: trip.startDate)) - \(dateFormatter.string(from: trip.endDate))"
    }

    private func upcomingTimeText(
        for item: ItineraryItem
    ) -> String {
        let dateText = dateFormatter.string(from: item.date)

        guard let startTime = item.startTime else {
            return dateText
        }

        if let endTime = item.endTime {
            return "\(dateText), \(timeFormatter.string(from: startTime)) - \(timeFormatter.string(from: endTime))"
        }

        return "\(dateText), \(timeFormatter.string(from: startTime))"
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

private struct HubPlaceholderView: View {
    let title: String
    let message: String

    var body: some View {
        EmptyStateView(
            systemImage: "sparkles",
            title: title,
            message: message
        )
        .padding(SmartTripSpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SmartTripColors.background)
        .navigationTitle(title)
    }
}
