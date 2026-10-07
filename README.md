# SmartTrip 2.0

SmartTrip 2.0 is an iOS travel-planning app for travellers who collect ideas from many places, organise them by trip, turn them into itinerary plans, and preserve meaningful memories after the journey. The app keeps the core planning and memory workflow local-first with Core Data while exposing domain logic through ViewModels, Use Cases, repository protocols, and Core Data repository implementations.

## Trip Invitations

SmartTrip can share a Trip-specific invitation through the native iOS share sheet, including the Trip name, destination, and dates. This is an invitation-sharing handoff only: real-time multi-device collaboration and synchronization are outside the current MVP.

## Domain Context

Travellers often discover useful trip information outside the planning app: a Safari article, an Apple Maps place, selected text in Notes, or a compatible social/shared URL. While travelling, they also need lightweight prompts to capture memories before details fade. SmartTrip is designed to reduce friction across the travel lifecycle: discover, plan, travel, capture, and remember.

## Main App Architecture

The main app keeps persistence behind domain-facing boundaries:

```text
View
-> ViewModel
-> Use Case
-> Repository Protocol
-> Core Data Repository
-> Core Data
```

Core Data is used for production persistence because Trips, Saved Places, Itinerary Items, and Journey Capsule Memories are structured travel data that must remain available after relaunch and during poor connectivity. The app does not expose Core Data entities directly to SwiftUI views or Use Cases.

The primary business-operation path is the diagram above. Some simple read and delete operations appropriately use the shorter `View -> ViewModel -> Repository Protocol` path. Views and ViewModels never access Core Data directly; Core Data is configured in app startup/dependency composition and used behind repositories in the Data layer. The persisted entities are `Trip`, `SavedPlace`, `ItineraryItem`, and `Memory`, with relationships that keep each trip's planning and memory records together.

Trip memory persistence follows the same app architecture:

```text
JourneyCapsuleView
-> JourneyCapsuleViewModel
-> CaptureJourneyMemoryUseCase / MemoryRepository
-> CoreDataMemoryRepository
-> Core Data
```

Each Trip can have many Memories. A Memory stores the smallest useful Journey Capsule record: Trip relationship, location/place when available, written reflection, captured date, and an optional photo reference. Large image binary storage is intentionally deferred until SmartTrip has a dedicated image-storage strategy.

## Action Extension: SmartTrip Discovery

SmartTrip Discovery helps travellers turn travel inspiration found outside SmartTrip into a structured travel brief. It appears for compatible URL and plain-text content from sources such as Safari, Maps, Notes or selected text, and compatible Instagram/shared URLs when the host app exposes standard share content.

The extension receives available URL/text, extracts a likely place or topic and location when possible, generates a concise travel-oriented summary, optionally suggests 0-3 related places using MapKit, and lets the traveller review or edit the result before completing. The edited result is formatted as plain text and returned to the host app through `NSExtensionContext`.

### Why an Action Extension?

Travellers commonly discover trip ideas while browsing, reading maps, checking social links, or collecting recommendations from outside the main planning app. Without an extension, they must copy content, switch apps, remember the relevant details, and rewrite the idea manually. SmartTrip Discovery reduces that context switching by processing the shared content in place, while still giving the traveller a review/edit step so imperfect extraction does not become trusted data automatically. Returning the formatted result to the host app keeps the extension lightweight and avoids coupling it to SmartTrip persistence.

### Extension Architecture

```text
Host app content
-> Action Extension
-> ActionExtensionInputReader
-> ActionTravelInput
-> TravelContentProcessor
-> TravelDiscoveryResult
-> Review/Edit UI
-> TravelDiscoveryFormatter
-> NSExtensionContext.completeRequest(...)
```

Recommendation generation is dependency-injected:

```text
TravelContentProcessor
-> TravelRecommendationProviding

Production
-> MapKitTravelRecommendationService

Tests
-> MockTravelRecommendationProvider
```

### Core Data Boundary

The Action Extension does not access Core Data, repositories, Use Cases, or App Groups. It is a separate platform integration that processes and returns formatted content. The SmartTrip main app remains responsible for persisting Trips, Saved Places, Itinerary Items, and Memories through the existing Repository + Core Data architecture.

**App Group: Not used.** SmartTrip's Action Extension returns processed content to the host application, while the Notification Content Extension consumes notification payload data. The final extension design therefore does not require shared App Group storage.

### Supported Inputs

- URL
- Plain text
- URL + text when the host provides both

Primary demonstration sources are Safari, Maps, and Notes or selected text. Instagram support is best-effort and depends on whether Instagram exposes standard URL or text content to the extension.

### Processing Behaviour

- Preserves the source URL where available.
- Extracts a place or travel topic using deterministic local processing.
- Extracts a location where obvious from the shared content.
- Generates a conservative travel summary without claiming AI/NLP understanding.
- Uses MapKit only for optional related-place recommendations.
- Treats recommendation/network failure as non-fatal.
- Allows the user to edit place/topic, location, summary, and remove recommendations before completing.

### Failure Behaviour

- Unsupported or empty input shows a human-readable error.
- Missing location remains editable rather than blocking completion.
- Offline text processing still works; recommendations may be empty.
- Cancel dismisses cleanly without returning content.
- Done returns one formatted result and guards against repeated completion.

## Notification Content Extension: Journey Capsule Reminder

`SmartTripNotificationExtension` supports Journey Capsule reminders while a traveller is actively on a trip. The main app schedules a local notification using the `JOURNEY_CAPSULE_REMINDER` category and a `JourneyCapsuleNotificationPayload` containing Trip context such as `tripID`, Trip name, optional destination, optional trip day, and prompt text.

The custom notification is SmartTrip-branded and notification-sized. It reminds the traveller to capture a fresh moment and routes them back to the relevant Journey Capsule when tapped. The notification itself is not postcard-styled; the postcard-inspired design belongs inside the Journey Capsule experience after a Memory has been saved.

### Why a Notification Content Extension?

Travellers may forget to record memories while actively travelling, even though those memories are easiest to capture while the experience is fresh. A Journey Capsule reminder reaches the traveller without requiring them to remember to reopen SmartTrip, and Trip context makes the prompt feel relevant instead of generic. When the traveller taps the notification, SmartTrip routes directly to the correct Journey Capsule so they can quickly capture the moment and return to their trip. The custom notification keeps the reminder concise and recognisable, while postcard-style Memories inside the app make captured moments persistent, visual, and revisitable after the journey.

### Notification Flow

```text
Main app
-> JourneyCapsuleNotificationPayload
-> JourneyCapsuleNotificationScheduling
-> UNUserNotificationCenter

System
-> JOURNEY_CAPSULE_REMINDER

SmartTripNotificationExtension
-> UNNotification
-> JourneyCapsuleNotificationPayload
-> custom SmartTrip notification UI

User tap
-> main app
-> tripID routing
-> relevant Journey Capsule
```

`SmartTripNotificationExtension` does not access Core Data, repositories, Use Cases, `PersistenceController`, or Action Extension code. It only renders notification content from the payload. The main app owns scheduling, routing, and all Memory persistence.

**App Group: Not used.** The notification extension consumes the payload supplied with the notification; it does not need shared-container storage.

## Journey Capsule

Journey Capsule is the persistent memory experience for each Trip. It supports persisted Memories, a quick Capture a Moment flow, place/location, a short reflection, captured date, postcard-inspired Memory cards, postcard-style detail views, and empty/loading/error states.

The capture flow is intentionally lightweight:

```text
Trip
-> Journey Capsule reminder scheduled
-> custom notification
-> user taps notification
-> relevant Journey Capsule
-> Capture a Moment
-> CaptureJourneyMemoryUseCase
-> MemoryRepository
-> CoreDataMemoryRepository
-> Core Data
-> postcard-style Memory displayed
```

The Journey Capsule empty state shows a clear `Capture a Moment` action, and populated capsules retain add-another entry points through the header action and capture tile. Saving a valid Memory dismisses the capture sheet, refreshes the Journey Capsule, and displays the new postcard-style Memory immediately.

## Testing Strategy

Pure Action Extension logic is compiled into both `SmartTripActionExtension` and `smarttrip2.0Tests`:

- `ActionTravelInput`
- `TravelDiscoveryResult`
- `TravelContentProcessor`
- `TravelDiscoveryFormatter`
- `TravelRecommendationProviding`

Extension runtime code remains extension-only:

- `ActionViewController`
- `ActionExtensionInputReader`
- `MapKitTravelRecommendationService`

Tests use `MockTravelRecommendationProvider` and do not require live MapKit, internet access, Safari, Maps, Instagram, or a physical device. The system share/action lifecycle is validated manually because it depends on host-app behaviour.

The test suite uses mock repositories and providers to keep Use Case and ViewModel tests independent from production persistence and external services. Coverage includes Use Cases, Core Data persistence and scheduling transaction integrity, Action Extension pure logic, Journey Capsule behaviour, notification payloads/scheduling/routing, and UI launch coverage.

Final automated test execution on a connected iPhone:

- Unit tests: 70 passed / 0 failed
- UI tests: 3 passed / 0 failed
- Total: 73 passed / 0 failed

## Setup

1. Clone the repository.
2. Open `smarttrip2.0.xcodeproj` in Xcode.
3. Select the shared `smarttrip2.0` scheme and a simulator or connected iPhone.
4. Build and run with Product -> Build or Product -> Run.
5. Run the shared `smarttrip2.0.xctestplan` with Product -> Test.
6. Select `SmartTripActionExtension` or `SmartTripNotificationExtension` from the scheme picker to build either extension directly when validating extension-specific changes.

The shared schemes and test plan are committed to Git.
