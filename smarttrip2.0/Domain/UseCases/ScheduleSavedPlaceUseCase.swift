import Foundation

struct ScheduleSavedPlaceUseCase {
    private let tripRepository: any TripRepository
    private let savedPlaceRepository: any SavedPlaceRepository
    private let itineraryRepository: any ItineraryRepository
    private let calendar: Calendar

    init(
        tripRepository: any TripRepository,
        savedPlaceRepository: any SavedPlaceRepository,
        itineraryRepository: any ItineraryRepository,
        calendar: Calendar = .current
    ) {
        self.tripRepository = tripRepository
        self.savedPlaceRepository = savedPlaceRepository
        self.itineraryRepository = itineraryRepository
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

        let scheduledPlace = SavedPlace(
            id: savedPlace.id,
            tripID: savedPlace.tripID,
            name: savedPlace.name,
            url: savedPlace.url,
            notes: savedPlace.notes,
            status: .scheduled,
            dateSaved: savedPlace.dateSaved
        )

        try itineraryRepository.saveItineraryItem(item)
        try savedPlaceRepository.updateSavedPlace(scheduledPlace)

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
