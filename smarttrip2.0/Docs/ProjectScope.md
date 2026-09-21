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

## Proposed Persistence

Core Data will be used for the initial implementation.

Potential entities:

- Trip
- SavedPlace
- ItineraryItem
- TripMemory
- TripMember

The data model will contain relationships between trips and their related Saved Places, itinerary items, members, and memories.

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

One planned domain query is:

> Fetch all remaining itinerary activities for the active trip that are scheduled for today and have not yet occurred.

This query can support both the main itinerary interface and the Widget.

## Development Principle

SmartTrip 2.0 will follow:

Views  
→ ViewModels  
→ Use Cases  
→ Repository Protocols  
→ Core Data Repository  
→ Core Data

Views and ViewModels will not access Core Data directly.

## Development Notes

Throughout implementation, record:

- original design decision
- problem encountered
- change made
- reason for the change
- resulting trade-off

These notes will later support the Assessment 3 reflective report.
