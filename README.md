# SmartTrip 2.0

SmartTrip 2.0 is an iOS travel-planning app for travellers who collect ideas from many places, organise them by trip, and turn them into itinerary plans. The app keeps the core planning workflow local-first with Core Data while exposing domain logic through ViewModels, Use Cases, repository protocols, and Core Data repository implementations.

## Domain Context

Travellers often discover useful trip information outside the planning app: a Safari article, an Apple Maps place, selected text in Notes, or a compatible social/shared URL. SmartTrip is designed to reduce the friction between discovery and planning by helping users capture and structure those ideas without manually retyping everything later.

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

Core Data is used for production persistence because Trips, Saved Places, and Itinerary Items are structured planning data that must remain available after relaunch and during poor connectivity. The app does not expose Core Data entities directly to SwiftUI views or Use Cases.

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

The Action Extension does not access Core Data, repositories, Use Cases, App Groups, or CloudKit. It is a separate platform integration that processes and returns formatted content. The SmartTrip main app remains responsible for persisting Trips, Saved Places, and Itinerary Items through the existing Repository + Core Data architecture.

No App Group identifier is used because the selected Action Extension workflow does not require shared-container communication.

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

Latest full validation:

- Unit tests: 40 passed / 0 failed
- UI tests: 3 passed / 0 failed
- Total: 43 passed / 0 failed
- Action Extension-related automated tests: 15 passed / 0 failed

## Setup

Open `smarttrip2.0.xcodeproj` in Xcode, select the main `smarttrip2.0` scheme, then build or run tests with Product -> Build and Product -> Test. The Action Extension target is embedded in the main app and can also be built directly when validating extension-specific changes.
