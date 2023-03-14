//
//  ContentView.swift
//  DoNotBeEvil
//
//  Created by Yan on 2022/10/17.
//  Copyright © 2022 Yan. All rights reserved.
//

import SwiftUI
import EventKit

struct CalenderEventItem: Identifiable {
    var id: UUID = UUID()
    var task: String
    var title: String
}

struct ContentView: View {
    @State
    var calenderEvents = getCalenderList()

    var body: some View {
        VStack {
            Section(header: Text("其他内容")) {
                List {
                    ForEach($calenderEvents) { item in
                        HStack {
                            VStack {
                                Text(item.task.wrappedValue).fontWeight(.heavy).padding(.bottom, 3)
                                Text("起:2023-03-08 - 终:2023-03-08").font(.footnote)
                            }.padding(.leading)
                            Text("起")
                        }
                    }
                }
            }
//            Section(header: Text("待办事项")) {
//                ForEach($calenderEvents) { item in
//                    HStack {
//                        Image(systemName: item.imgName.wrappedValue)
//                        Text(item.task.wrappedValue)
//                    }
//                }
//            }
        }
    }
}

//func convertTest(events: [EKEvent]) -> [CalenderEventItem] {
//    var sequence = [CalenderEventItem]()
//    for _ in 0...events.count {
//        var a = CalendarEventItem()
//        sequence.append(a)
//    }
//    return sequence
//}

func getCalenderList() -> [CalenderEventItem] {
    [
        CalenderEventItem(task: "写一篇SwiftUI文章", title: "惊蛰"),
        CalenderEventItem(task: "看WWDC视频", title: "惊蛰"),
        CalenderEventItem(task: "定外卖", title: "惊蛰"),
        CalenderEventItem(task: "关注OldBirds公众号", title: "惊蛰"),
        CalenderEventItem(task: "6点半跑步2公里", title: "惊蛰"),
    ]
}

func scannerEvents(dayRanges: Int) {
    let eventStore = EKEventStore()
    // 授权访问日历事件数据
    print("====\(eventStore.calendars(for: .event).count)")
    eventStore.requestAccess(to: .event) { (granted, error) in
        if (granted) && (error == nil) {
            var events = getCalendarEvents(eventStore: eventStore, dayRanges: dayRanges)
            for eventItem in events {
            }
            print(events.count)
            print("=====")
        } else {
            // 授权失败，需要提示用户授权日历事件数据的数据访问权限
        }
    }
}

func getCalendarEvents(eventStore: EKEventStore, dayRanges: Int) -> [EKEvent] {
    // 获取指定时间范围内的所有日历事件
    let timeRang: TimeInterval = 60 * 60 * 24
    let startDate = Date().addingTimeInterval(timeRang * Double(dayRanges))
    let endDate = Date().addingTimeInterval(timeRang)
    print("查询范围 开始:\(startDate) 结束:\(endDate)")

    let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
    return eventStore.events(matching: predicate)
            .filter { event in event.calendar.type == EKCalendarType.calDAV }
            .filter { event in event.calendar.source.title == "iCloud" }
            .filter { event in !event.calendar.isSubscribed }
            .filter { event in !event.calendar.isNew } as [EKEvent]
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
