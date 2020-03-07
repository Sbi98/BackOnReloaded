//
//  CalendarController.swift
//  BackOn
//
//  Created by Vincenzo Riccio on 03/03/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import EventKit

class CalendarController {
    static var eventStore = EKEventStore()
    static var destCalendar: EKCalendar?
    static var authorized = true
    
    static func initController() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            print("Calendar access granted")
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
    
    static fileprivate func initCalendar() {
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
    
    static func addEvent(title: String, startDate: Date, endDate: Date?, relativeAlarmTime: TimeInterval = -60) {
        if authorized {
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate ?? startDate
            event.addAlarm(EKAlarm(relativeOffset: relativeAlarmTime))
            event.calendar = destCalendar!
            do {
                try eventStore.save(event, span: .thisEvent)
            } catch {print(error.localizedDescription)}
        } else {
            print("Impossibile aggiungere un evento! Non sei autorizzato")
        }
    }
    
    static func isNotBusy(when date: Date) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: date, end: date.addingTimeInterval(3600), calendars: nil)
        let events = eventStore.events(matching: predicate)
        return events.isEmpty
    }
}
