# SmartTrip 2.0 — Project Scope

## Primary Stakeholder

A member of a small group of leisure travellers who collaboratively researches, organises, and documents a multi-stop trip.

## Problem Statement

Group travellers struggle to capture, coordinate, and act on trip information that is scattered across messages, maps, booking confirmations, browser pages, and other travel sources.

This fragmentation can result in repeated searching, forgotten suggestions, duplicated planning effort, unclear itinerary changes, and trip memories being distributed across different devices and message threads.

## Project Goal

SmartTrip 2.0 is a collaborative trip workspace that connects travel discovery, group planning, itinerary coordination, and shared memories.

The application aims to provide a simpler workflow for turning travel ideas discovered across different sources into an organised group itinerary.

## Primary Workflow

Discover  
→ Capture  
→ Saved Places  
→ Group Decision  
→ Schedule  
→ Itinerary  
→ Travel  
→ Memories

## Core Domain Concepts

### Trip

Represents the overall journey being planned by the travelling group.

### Saved Place

Represents a place or activity that a traveller has discovered but that the group has not yet committed to.

Possible statuses:

- Idea
- Shortlisted
- Scheduled
- Rejected

### Itinerary Item

Represents an activity that has been confirmed and scheduled as part of the trip.

### Trip Memory

Represents a photo or caption associated with an activity or experience from the trip.

### Trip Member

Represents a traveller participating in the group trip.

## MVP Features

### Core Features

- Trip creation and management
- Saved Places
- Collaborative trip planning
- Itinerary management
- Group members
- Journey Capsule / trip memories

### Supporting Features

- Expense tracking
- Budget overview
- Weather
- Flight information

### Deferred Features

The following features are outside the initial Assessment 3 scope:

- AI itinerary generation
- Automatic route optimisation
- Live venue busyness
- Automatic itinerary rearrangement
- Hotel booking
- Full social media feed
- Automatic Instagram publishing

## Core Screens

### 1. My Trips

Allows travellers to view, create, and select their trips.

### 2. Trip Hub

Provides an overview of the selected trip, including upcoming activities, Saved Places, members, expenses, and memories.

### 3. Saved Places

Stores places that travellers have discovered but have not yet added to the itinerary.

### 4. Itinerary

Shows the group's confirmed trip schedule by date and time.

### 5. Journey Capsule

Displays photos and memories associated with completed trip activities.

## System Extensions

### Share Extension

#### User Scenario

A traveller discovers a restaurant, attraction, map location, or travel resource while using another application such as Safari.

Instead of copying the information into a group chat and manually entering it into SmartTrip later, the traveller can use:

Share → SmartTrip

The shared URL is captured as a SavedPlace associated with the selected Trip.

#### Initial Supported Content

- Web URLs
- Map URLs
- Plain text may be considered as a future enhancement.

## Widget Extension

### User Scenario

While travelling, a group member needs to quickly determine what activity is happening next without navigating through the full SmartTrip application.

### Small Widget

Displays:

- Next activity
- Start time
- Location

### Medium Widget

Displays:

- Next two or three activities for the current day
- Start times
- Locations

## Production Persistence

SmartTrip uses Core Data as its production persistent database.

Core Data fits the product because Trips, Saved Places, and Itinerary Items are structured relational planning data. Travellers need this information to remain available after relaunch, continue working with poor or unavailable network connectivity, and stay scoped to the correct Trip. Core Data also integrates naturally with the iOS application while allowing the rest of the app to depend on repository protocols instead of persistence implementation details.

Cloud synchronization remains a possible future enhancement, but the core planning workflow is intentionally local-first and does not require network access.

### Persisted Entities

The current production model persists:

- TripEntity: the overall journey being planned.
- SavedPlaceEntity: an idea, attraction, restaurant, or activity being considered for a Trip.
- ItineraryItemEntity: a committed scheduled activity in a Trip itinerary.

Conceptual relationships:

- TripEntity 1 -> many SavedPlaceEntity
- TripEntity 1 -> many ItineraryItemEntity
- SavedPlaceEntity many -> 1 TripEntity
- ItineraryItemEntity many -> 1 TripEntity

Saved Places and Itinerary Items are intentionally separate concepts. A Saved Place is an idea being considered; an Itinerary Item is a scheduled commitment.

### Repository Architecture

Persistence access is defined by domain-facing repository protocols:

- TripRepository
- SavedPlaceRepository
- ItineraryRepository

Production implementations are:

- CoreDataTripRepository
- CoreDataSavedPlaceRepository
- CoreDataItineraryRepository

The protocols expose domain models rather than Core Data entities. Views and ViewModels never fetch Core Data directly. Use Case tests use mock repositories with in-memory domain collections, while persistence validation tests exercise the Core Data repositories against a test store.

## Planned Use Cases

### CaptureSharedPlaceUseCase

Purpose:

Capture content discovered outside SmartTrip as a Saved Place.

Planned business rules:

- A trip must be selected.
- Shared content must be supported.
- Duplicate URLs should not be saved to the same trip.

### ScheduleSavedPlaceUseCase

Purpose:

Convert a Saved Place into a confirmed Itinerary Item.

Planned business rules:

- The scheduled activity must fall within the trip dates.
- The Saved Place cannot already be scheduled.
- Required scheduling information must exist.

### AttachTripMemoryUseCase

Purpose:

Associate a memory with a trip or itinerary activity.

Planned business rules:

- The referenced trip or activity must exist.
- The memory must belong to the correct trip.
- Only supported content should be stored.

### Optional: CreateTripUseCase

Purpose:

Create a valid trip.

Planned business rules:

- Required trip information must exist.
- End date cannot be before start date.

## Meaningful Database Query

SmartTrip includes a repository-backed query for upcoming itinerary activities:

> Fetch upcoming Itinerary Items for a selected Trip where the scheduled start time is at or after a supplied date, sorted chronologically.

This query is implemented in the Core Data itinerary repository using the selected Trip relationship and date/time predicates. It represents a real SmartTrip domain condition because travellers need to see the next confirmed activities for the Trip they are currently planning or travelling.

## Offline and Relaunch Behaviour

The core SmartTrip workflow is local-first:

- Trips remain available offline.
- Saved Places remain available offline.
- Scheduling works offline.
- Itinerary Items remain available offline.
- Persisted relationships survive app termination and relaunch.
- No network connection is required for the core planning workflow.

No cloud synchronization is claimed for the current production persistence layer.

## Testing Strategy

SmartTrip validates persistence and business behaviour at multiple layers:

- Use Case tests exercise domain rules through mock repository implementations.
- Core Data persistence tests validate repository-backed Trip, Saved Place, and Itinerary Item persistence.
- UI tests cover core launch and navigation behaviour.

The automated suite covers valid operations, boundary conditions, typed domain errors, cross-Trip persistence isolation, duplicate prevention, and invalid scheduling behaviour.

## Development Principle

SmartTrip 2.0 follows:

Views  
→ ViewModels  
→ Use Cases  
→ Repository Protocols  
→ Core Data Repository  
→ Core Data

Views and ViewModels do not access Core Data directly.

## Phase 2 Completion

Phase 2 established the Core Data and Repository layer foundation.

Completed scope:

- Core Data model foundation
- Trip, Saved Place, and Itinerary Item persistence entities
- PersistenceController
- Repository protocols
- Domain to Core Data mappers
- Core Data repository implementations for Trips, Saved Places, and Itinerary Items
- Upcoming itinerary predicate query
- App-level repository dependency wiring

Use Cases, ViewModel refactoring, WidgetKit, Share Extension, and App Groups remain outside Phase 2.

## Development Notes

Throughout implementation, record:

- original design decision
- problem encountered
- change made
- reason for the change
- resulting trade-off

These notes will later support the Assessment 3 reflective report.
