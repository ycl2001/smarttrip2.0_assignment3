import CoreLocation
import SwiftUI
import UIKit
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @State private var notificationPermission = NotificationPermissionStatus.loading
    let currentLocation: any CurrentLocationProviding

    var body: some View {
        NavigationStack {
            Form {
                notificationsSection
                privacyAndDataSection
                appSection
                supportSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await refreshNotificationPermission()
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else {
                    return
                }

                Task {
                    await refreshNotificationPermission()
                }
            }
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            NavigationLink {
                SettingsInformationView(
                    title: "Journey Capsule Reminders",
                    introduction: "Journey Capsule reminders are configured from each Trip's Journey Capsule.",
                    points: [
                        "Choose a future date and time from a Trip's Journey Capsule.",
                        "SmartTrip asks for notification permission only when you choose to set a reminder."
                    ]
                )
            } label: {
                SettingsStatusRow(
                    title: "Journey Capsule Reminders",
                    status: "Set per trip"
                )
            }
            .accessibilityLabel("Journey Capsule Reminders, set per trip")

            HStack {
                Text("Notification Permission")
                Spacer()
                Text(notificationPermission.displayText)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Notification Permission, \(notificationPermission.displayText)")

            if notificationPermission.canOpenSystemSettings {
                Button("Open Notification Settings") {
                    openNotificationSettings()
                }
                .foregroundStyle(SmartTripColors.primary)
                .accessibilityHint("Opens SmartTrip notification settings in the Settings app")
            }
        }
    }

    private var privacyAndDataSection: some View {
        Section("Privacy & Data") {
            NavigationLink {
                LocationAndMapsSettingsView(currentLocation: currentLocation)
            } label: {
                SettingsStatusRow(
                    title: "Location & Maps",
                    status: "Place suggestions"
                )
            }
            .accessibilityLabel("Location and Maps, used for place suggestions")

            NavigationLink {
                SettingsInformationView(
                    title: "Your Data",
                    introduction: "Your travel planning data stays on this device.",
                    points: [
                        "Trips are stored locally using Core Data.",
                        "Saved Places and Itinerary Items are stored with their Trip.",
                        "Journey Capsule Memories are stored locally.",
                        "MapKit is used for place suggestions.",
                        "SmartTrip does not currently provide cross-device Trip synchronisation."
                    ]
                )
            } label: {
                Text("Your Data")
            }

            NavigationLink {
                SettingsInformationView(
                    title: "Privacy Information",
                    introduction: "SmartTrip is designed as a local-first travel planner.",
                    points: [
                        "Trip planning and Journey Capsule data are stored locally on your device.",
                        "MapKit provides optional place suggestions as you type.",
                        "Journey Capsule reminders use local notifications when you grant iOS notification permission.",
                        "Notification permissions are controlled in iOS Settings.",
                        "CloudKit and App Group shared storage are not used in the current MVP."
                    ]
                )
            } label: {
                Text("Privacy Information")
            }
        }
    }

    private var appSection: some View {
        Section("App") {
            NavigationLink {
                SettingsInformationView(
                    title: "About SmartTrip",
                    introduction: "SmartTrip helps travellers collect trip ideas, organise itineraries, and capture memories in Journey Capsules.",
                    points: ["Version \(appVersionText)"]
                )
            } label: {
                Text("About SmartTrip")
            }

            HStack {
                Text("Version")
                Spacer()
                Text(appVersionText)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Version \(appVersionText)")
        }
    }

    private var supportSection: some View {
        Section("Support") {
            NavigationLink {
                SettingsInformationView(
                    title: "Help & Feedback",
                    introduction: "Quick help for the features available in SmartTrip today.",
                    points: [
                        "Journey Capsule reminders are configured from each Trip.",
                        "Place suggestions use MapKit.",
                        "Trip invitations use the native iOS share sheet."
                    ]
                )
            } label: {
                Text("Help & Feedback")
            }
        }
    }

    private var appVersionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(version) (\(build))"
    }

    @MainActor
    private func refreshNotificationPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationPermission = NotificationPermissionStatus(settings.authorizationStatus)
    }

    @MainActor
    private func openNotificationSettings() {
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }

        Task {
            await UIApplication.shared.open(url)
        }
    }
}

private struct LocationAndMapsSettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    let currentLocation: any CurrentLocationProviding
    @State private var status: CLAuthorizationStatus = .notDetermined

    var body: some View {
        Form {
            Section("Location") {
                HStack {
                    Text("Location Access")
                    Spacer()
                    Text(statusText)
                        .foregroundStyle(.secondary)
                }
                Text("SmartTrip only accesses your location when you choose \"Use My Current Location.\"")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if status == .denied {
                    Button("Open iOS Settings") { openAppSettings() }
                        .foregroundStyle(SmartTripColors.primary)
                } else if status == .notDetermined {
                    Text("Location permission is requested from Capture a Moment, not from Settings.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Maps") {
                LabeledContent("Place Suggestions", value: "Apple MapKit")
                Text("Used when searching for destinations, Saved Places, and Journey Capsule locations. Manual entry remains available without location permission.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Location & Maps")
        .navigationBarTitleDisplayMode(.inline)
        .task { status = currentLocation.authorizationStatus }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { status = currentLocation.authorizationStatus }
        }
    }

    private var statusText: String {
        switch status {
        case .notDetermined: "Not Requested"
        case .authorizedWhenInUse: "While Using"
        case .denied: "Off"
        case .restricted: "Restricted"
        case .authorizedAlways: "Allowed"
        @unknown default: "Off"
        }
    }

    @MainActor
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        Task { await UIApplication.shared.open(url) }
    }
}

private struct SettingsStatusRow: View {
    let title: String
    let status: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(status)
                .foregroundStyle(.secondary)
        }
    }
}

private struct SettingsInformationView: View {
    let title: String
    let introduction: String
    let points: [String]

    var body: some View {
        List {
            Section {
                Text(introduction)
                    .foregroundStyle(.secondary)
            }

            Section {
                ForEach(points, id: \.self) { point in
                    Label(point, systemImage: "checkmark")
                        .foregroundStyle(SmartTripColors.textPrimary)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private enum NotificationPermissionStatus {
    case loading
    case enabled
    case disabled
    case notConfigured

    init(_ authorizationStatus: UNAuthorizationStatus) {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            self = .enabled
        case .denied:
            self = .disabled
        case .notDetermined:
            self = .notConfigured
        @unknown default:
            self = .disabled
        }
    }

    var displayText: String {
        switch self {
        case .loading:
            "Checking…"
        case .enabled:
            "Enabled"
        case .disabled:
            "Disabled"
        case .notConfigured:
            "Not configured"
        }
    }

    var canOpenSystemSettings: Bool {
        self == .disabled
    }
}
