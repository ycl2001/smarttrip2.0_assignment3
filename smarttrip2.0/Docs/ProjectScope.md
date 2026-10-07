# SmartTrip 2.0 — Project Scope

## Project Positioning

SmartTrip 2.0 is a local-first travel planning and memory application. It helps travellers collect travel ideas, organise Saved Places into an itinerary, share Trip information using native iOS sharing, and capture memories during a journey through Journey Capsules.

## Primary Stakeholder

A leisure traveller planning individually or with a small group who collects travel ideas from multiple sources, organises an itinerary, shares Trip information, and records memories during the journey. SmartTrip does not currently support synchronous multi-user editing of the same Trip.

## Problem Statement

Travel planning information is fragmented across messages, browser pages, maps, notes, saved links, and booking or travel information. This can lead to repeated searching, lost ideas, fragmented planning, difficulty turning ideas into scheduled activities, and memories becoming separated from the Trip plan.

## Project Goal

The implemented MVP supports:

- creating and managing Trips;
- collecting Saved Places;
- scheduling committed Itinerary Items;
- sharing Trip invitation information through the native iOS share sheet;
- capturing Journey Capsule Memories; and
- using system integrations for discovery and local reminder notifications.

Native Trip sharing is implemented. Real-time collaborative editing and cloud synchronisation are outside the current MVP.

## Primary Workflow

Create Trip
→ Save Places
→ Schedule
→ Follow Itinerary
→ Capture Journey Memories
→ Remember

## Core Domain Concepts

### Trip

The overall journey, with a destination and inclusive start/end dates.

### SavedPlace

A travel idea under consideration for a Trip. A Saved Place can be an idea, shortlisted, scheduled, or rejected.

### ItineraryItem

A committed scheduled activity belonging to a Trip. Saved Places and Itinerary Items are separate so an idea is not treated as a confirmed plan until it is scheduled.

### Memory / Journey Capsule Memory

A captured Journey Capsule moment associated with a Trip, with an optional location, written reflection, captured date, and optional photo reference.

### Member and Invitation Context

The Members screen shows the current local organiser and can share Trip details through `ShareLink`. It does not persist or synchronise shared member state.

## Implemented MVP Features

- Trip creation and management
- Saved Places and itinerary scheduling
- Journey Capsule Memories
- native Trip invitation sharing through the iOS share sheet
- MapKit place autocomplete and optional current-location lookup
- Journey Capsule reminder scheduling and custom notification presentation
- Action Extension travel-content processing
- local Core Data persistence

## System Extensions

### SmartTrip Action Extension

The Action Extension processes travel-related URL and plain-text content from a host application:

Host application
→ Action Extension
→ read URL/text
→ process travel context
→ optional MapKit recommendations
→ review/edit
→ formatted output returned to the host

It does not directly write SmartTrip Core Data, automatically create a Saved Place, or require an App Group. It returns formatted output through `NSExtensionContext`.

### SmartTrip Notification Content Extension

The Notification Content Extension provides custom presentation for Journey Capsule reminder notifications:

Journey Capsule
→ traveller schedules reminder
→ main app schedules notification
→ `JOURNEY_CAPSULE_REMINDER` payload
→ SmartTripNotificationExtension
→ custom notification
→ tap routes to the relevant Trip/Journey Capsule

The production scheduling caller is in the main app. The extension does not access Core Data and does not require an App Group.

## Production Persistence and Offline Behaviour

`PersistenceController` owns the `NSPersistentContainer`, SmartTrip model, view context, and lightweight migration configuration. Core Data keeps local Trip data available across relaunches and while offline.

Persisted local data:

- Trips
- Saved Places
- Itinerary Items
- Journey Capsule Memories

Cloud sync and real-time collaboration are not implemented.

### Persisted Entities and Relationships

- `TripEntity` → many `SavedPlaceEntity`
- `TripEntity` → many `ItineraryItemEntity`
- `TripEntity` → many `MemoryEntity`

Each child entity belongs to one Trip. `SavedPlaceEntity`, `ItineraryItemEntity`, and `MemoryEntity` are not interchangeable records.

### Repository Architecture

Domain-facing protocols keep Core Data out of Views and ViewModels:

- `TripRepository` → `CoreDataTripRepository`
- `SavedPlaceRepository` → `CoreDataSavedPlaceRepository`
- `ItineraryRepository` → `CoreDataItineraryRepository`
- `MemoryRepository` → `CoreDataMemoryRepository`
- `SavedPlaceSchedulingRepository` → `CoreDataSavedPlaceSchedulingRepository`

The primary business path is:

View
→ ViewModel
→ Use Case
→ Repository Protocol
→ Core Data Repository
→ Core Data

Some simple reads and deletes use the appropriate shorter View → ViewModel → Repository Protocol path. Views and ViewModels do not directly access Core Data.

## Implemented Use Cases

### CreateTripUseCase

Creates a Trip after validating a name, destination, and inclusive date range (`endDate >= startDate`).

### CaptureSharedPlaceUseCase

Main-app use case that persists a Saved Place for a selected Trip and protects against duplicate source URLs. This is distinct from the Action Extension, which only processes and returns host content.

### ScheduleSavedPlaceUseCase

Validates that a Saved Place exists, is not already scheduled, and is scheduled on an inclusive Trip calendar day. It creates the `ItineraryItem` and updates Saved Place status through one atomic persistence operation.

### CaptureJourneyMemoryUseCase

Captures a valid Journey Capsule Memory for an existing Trip while retaining optional location and caption support.

## Deferred Features

The following are deliberately outside the current MVP:

- real-time collaboration and shared member state
- cloud synchronisation
- expense tracking and budget tools
- weather and flight integrations
- automatic itinerary generation or route optimisation
- hotel booking and social publishing

## Testing Strategy

Unit tests use mock repositories and providers to exercise Use Cases, ViewModels, and services. These include explicit inclusive Trip-date boundary tests.

Integration tests use the real in-memory Core Data stack to validate repository persistence, relationships, and transaction integrity.

UI tests cover app launch and navigation/workflows.

## Meaningful Database Query

The itinerary repository fetches upcoming Itinerary Items for a selected Trip whose scheduled start time is at or after a supplied date, sorted chronologically. This provides the Trip Hub's relevant next confirmed activities.
