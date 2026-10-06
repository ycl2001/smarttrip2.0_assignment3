import Foundation

struct ScheduleSavedPlaceUseCase {
    private let tripRepository: any TripRepository
    private let savedPlaceRepository: any SavedPlaceRepository
    private let schedulingRepository: any SavedPlaceSchedulingRepository
    private let calendar: Calendar

    init(
        tripRepository: any TripRepository,
        savedPlaceRepository: any SavedPlaceRepository,
        schedulingRepository: any SavedPlaceSchedulingRepository,
        calendar: Calendar = .current
    ) {
        self.tripRepository = tripRepository
        self.savedPlaceRepository = savedPlaceRepository
        self.schedulingRepository = schedulingRepository
        self.calendar = calendar
    }

    func execute(
        savedPlaceID: UUID,
        tripID: UUID,
        scheduledDate: Date,
        startTime: Date?,
        endTime: Date? = nil,
        notes: String? = nil,
        category: ItineraryCategory = .other
    ) throws -> ItineraryItem {
        guard let trip = try tripRepository.fetchTrip(id: tripID) else {
            throw ScheduleSavedPlaceError.tripNotFound
        }

        guard let savedPlace = try savedPlaceRepository.fetchSavedPlace(id: savedPlaceID) else {
            throw ScheduleSavedPlaceError.savedPlaceNotFound
        }

        guard savedPlace.tripID == tripID else {
            throw ScheduleSavedPlaceError.savedPlaceNotFound
        }

        guard savedPlace.status != .scheduled else {
            throw ScheduleSavedPlaceError.alreadyScheduled
        }

        guard isDate(scheduledDate, inside: trip) else {
            throw ScheduleSavedPlaceError.outsideTripDates
        }

        let title = savedPlace.name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty, let startTime else {
            throw ScheduleSavedPlaceError.missingSchedule
        }

        let item = ItineraryItem(
            tripID: tripID,
            sourceSavedPlaceID: savedPlace.id,
            title: title,
            location: title,
            date: scheduledDate,
            startTime: startTime,
            endTime: endTime,
            notes: notes ?? savedPlace.notes,
            category: category
        )

        do {
            try schedulingRepository.schedule(
                savedPlaceID: savedPlace.id,
                itineraryItem: item
            )
        } catch {
            throw ScheduleSavedPlaceError.persistenceFailed
        }

        return item
    }

    private func isDate(
        _ date: Date,
        inside trip: Trip
    ) -> Bool {
        let scheduledDay = calendar.startOfDay(for: date)
        let startDay = calendar.startOfDay(for: trip.startDate)
        let endDay = calendar.startOfDay(for: trip.endDate)

        return scheduledDay >= startDay && scheduledDay <= endDay
    }
}
