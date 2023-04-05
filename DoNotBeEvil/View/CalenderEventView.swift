//
//  CalenderEventView.swift
//  DoNotBeEvil
//
//  Created by Yan on 2022/10/27.
//  Copyright © 2022 Yan. All rights reserved.
//

import SwiftUI
import EventKit

struct CalenderEventItem: Identifiable {
    var id:           String
    var title:        String
    var startDate:    Date
    var endDate:      Date
    var status:       Int
    var allowsModify: Bool
}

/**
 时间格式转换器
 */
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
}()

struct CalenderEventView: View {
    @State private var calenderEvents = getCalenderList()
    @State private var isChecked: Bool = false

    var body: some View {
        VStack {
            Section {
                List {
                    ForEach($calenderEvents) { item in
                        HStack(spacing: 3) {
                            Toggle(isOn: $isChecked) {
                                Text("")
                            }
                            .toggleStyle(CheckboxStyle())
                            .onTapGesture {
                                $isChecked.wrappedValue.toggle()
                            }

                            VStack(alignment: .leading, spacing: 0) {
                                Text(item.title.wrappedValue.count > 18 ? item.title.wrappedValue.prefix(18) + "..." : item.title.wrappedValue)
                                        .padding(.bottom, 3)
                                Text("起:\(dateFormatter.string(from: item.startDate.wrappedValue)) - 终:\(dateFormatter.string(from: item.endDate.wrappedValue))")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
    }
}


/**
 获取自定义日历事件数据

 - Returns:
 */
func getCalenderList() -> [CalenderEventItem] {
    // 授权访问
    let eventStore = EKEventStore()
    grantedScannerEvents(eventStore: eventStore)

    let events = getCalendarEvents(eventStore: eventStore, dayRanges: -365)
    var calenderEvents: [CalenderEventItem] = []
    events.forEach { eventItem in
        calenderEvents.append(convertCalendarEvents(event: eventItem))
    }
    return calenderEvents
}

/**
 将事件转换为可迭代访问的对象

 - Parameter event:
 - Returns:
 */
func convertCalendarEvents(event: EKEvent) -> CalenderEventItem {
    CalenderEventItem(id: event.eventIdentifier,
                      title: event.title.description,
                      startDate: event.startDate,
                      endDate: event.endDate,
                      status: event.status.rawValue,
                      allowsModify: event.calendar.allowsContentModifications)
}

 /**
 删除日历事件

  - Parameter eventIdentifier:
  */
func removeCalendarEvent(eventIdentifier: String) {
    let eventStore = EKEventStore()
    let event = eventStore.event(withIdentifier: eventIdentifier) ?? EKEvent(eventStore: eventStore)
    do {
        try eventStore.remove(event, span: .thisEvent, commit: true)
    } catch {
    }
}

/**
 获取日历事件数据

 - Parameters:
   - eventStore: 事件对象
   - dayRanges: 查询时间范围
 - Returns:
 */
func getCalendarEvents(eventStore: EKEventStore, dayRanges: Int) -> [EKEvent] {
    // 获取指定时间范围内的所有日历事件
    let dayTimeRang: TimeInterval = 60 * 60 * 24
    let startDate = Date().addingTimeInterval(dayTimeRang * Double(dayRanges))
    let endDate = Date().addingTimeInterval(dayTimeRang)
    print("事件查询范围 开始:\(dateFormatter.string(from: startDate)) 结束:\(dateFormatter.string(from: endDate))")

    let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
    return eventStore.events(matching: predicate)
            .sorted(by: { $0.compareStartDate(with: $1) == .orderedDescending })
            .filter { event in event.calendar.type == EKCalendarType.calDAV }
            .filter { event in event.calendar.source.title == "iCloud" }
            .filter { event in !event.calendar.isSubscribed }
            .filter { event in !event.calendar.isNew } as [EKEvent]
}

/**
 同步访问日历事件进行授权

 - Parameter eventStore:
 */
func grantedScannerEvents(eventStore: EKEventStore) {
    // 通过信号量将默认的异步改成同步的访问方式
    let semaphore = DispatchSemaphore(value: 0)
    eventStore.requestAccess(to: .event) { (granted, error) in
        if (granted) && (error == nil) {
            // 用户已授权，可以访问日历事件数据
            semaphore.signal()
        } else {
            // 用户未授权，无法访问日历事件数据
            semaphore.signal()
        }
    }
    semaphore.wait()
}

struct CheckboxStyle: ToggleStyle {
    let checkIcon   = "square"
    let checkedIcon = "square.fill"
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? checkedIcon : checkIcon)
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(configuration.isOn ? .red : .gray)
            configuration.label
        }
    }
}

#if DEBUG
struct CalenderEventView_Previews: PreviewProvider {
    static var previews: some View {
        CalenderEventView()
    }
}
#endif