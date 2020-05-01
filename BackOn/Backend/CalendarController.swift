//
//  CalendarController.swift
//  BackOn
//
//  Created by Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro on 03/03/2020.
//  Copyright © 2020 Riccio Vincenzo, Sorrentino Giancarlo, Triuzzi Emanuele, Zanfardino Gennaro. All rights reserved.
//

import EventKit

class CalendarController {
    static var eventStore = EKEventStore()
    static var destCalendar: EKCalendar?
    static var authorized = false
    
    static func initController() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            authorized = true
            initCalendar()
        case .denied:
            print("Calendar access denied")
            authorized = false
        case .notDetermined, .restricted:
            eventStore.requestAccess(to: .event) { granted, error in
                if granted {
                    print("Calendar access granted")
                    self.authorized = true
                    initCalendar()
                } else {
                    print("Calendar access denied")
                    self.authorized = false
                }
            }
        default:
            print("Case Default")
            authorized = false
        }
    }
    
    static private func initCalendar() {
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            if calendar.title == "BackOn Tasks" {
                destCalendar = calendar
            }
        }
        if destCalendar == nil {
            destCalendar = EKCalendar(for: .event, eventStore: eventStore)
            destCalendar!.title = "BackOn Tasks"
            destCalendar!.source = eventStore.defaultCalendarForNewEvents?.source
            do {
                try eventStore.saveCalendar(destCalendar!, commit:true)
            } catch {print(error.localizedDescription)}
        }
    }
    
    static func addTask(task: Task, needer: User) -> Bool {
        return addEvent(title: "Help \(needer.name) with \(task.title)", startDate: task.date, notes: task._id)
    }
    
    static func addRequest(request: Request) -> Bool {
        return addEvent(title: "You requested help with \(request.title)", startDate: request.date, notes: request._id)
    }
    
    static func remove(_ task: Task) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: task.date, end: task.date.addingTimeInterval(120), calendars: [destCalendar!])
        let events = eventStore.events(matching: predicate)
        for event in events {
            if let note = event.notes, note == task._id {
                do {
                    try eventStore.remove(event, span: .thisEvent)
                    return true
                } catch {print("Error while removing the event from the calendar"); return false}
            }
        }
        print("No event matching the taskID")
        return false
    }
    
    static func addEvent(title: String, startDate: Date, endDate: Date? = nil, relativeAlarmTime: TimeInterval = -60, notes: String? = nil) -> Bool {
        guard authorized else {print("You don't have the permission to add an event"); return false}
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate ?? startDate
        event.notes = notes
        event.addAlarm(EKAlarm(relativeOffset: relativeAlarmTime))
        event.calendar = destCalendar!
        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {print(error.localizedDescription); return false}
    }
    
    static func isBusy(when date: Date) -> Bool { //controlla che non ho impegni in [data-10min:data+10min]
        let predicate = eventStore.predicateForEvents(withStart: date.addingTimeInterval(-600), end: date.addingTimeInterval(600), calendars: nil)
        let events = eventStore.events(matching: predicate)
        guard !events.isEmpty else { return false }
        for event in events {
            if !event.isAllDay {
                return true
            }
        }
        return false
    }
}
