//
//  CalenderEventView.swift
//  DoNotBeEvil
//
//  Created by Yan on 2022/10/27.
//  Copyright © 2022 Yan. All rights reserved.
//

import SwiftUI
import EventKit
import NotificationCenter

struct CalenderEventItem: Identifiable {
    var id:           String
    var title:        String
    var startDate:    Date
    var endDate:      Date
    var status:       Int
    var allowsModify: Bool
    var checked:      Bool = false
}

var selectedCalenderEventItem: [String] = []

struct CalenderEventView: View {
    @State var isRefresh = false
    @State var isMore = false
    
    @State var textArr : Array<String> = []
    @State var count = 4
    @State private var calenderEvents = getCalenderList()

    var body: some View {
        VStack {
            /*
             offDown: 列表数据滑动总高
             listH: 列表高度
             refreshing: 下拉刷新加载UI的开关
             isMore: 加载更多UI的开关
             */
            RefreshScrollView(offDown: CGFloat(textArr.count) * 40.0,
                              listH: ScreenH - kNavHeight - kBottomSafeHeight,
                              refreshing: $isRefresh,
                              isMore: $isMore) {
                // 下拉刷新触发
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    // 刷新完成，关闭刷新
                    self.loadData()
                    isRefresh = false
                })
            } moreTrigger: {
                // 上拉加载更多触发
//                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
//                    // 加载完成，关闭加载
//                    for i in 0...10{
//                        textArr.append(String("\(i + textArr.count) Hello, world!"))
//                    }
                    isMore = false
//                })
            } content: {
                // 列表内容
//                VStack(spacing: 0){
//                    ForEach(0..<(textArr.count),id: \.self) { index in
//                        VStack{
//                            HStack {
//                                Image(systemName: "car")
//                                Text(textArr[index] )
//                            }
//                        }
//                    }
//                }
                VStack(alignment: .leading) {
                    ForEach($calenderEvents) { item in
                        CalenderEventItemView(eventItem: item)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(rawValue: "deleteNotification"))) { notification in
                        print("onReceive notification\(notification)")
                        if selectedCalenderEventItem.count > 0 {
                            selectedCalenderEventItem.forEach { eventId in
                                print("delete\(eventId)")
                                removeCalendarEvent(eventIdentifier: eventId)
                                let indexOf = selectedCalenderEventItem.firstIndex(of: eventId)
                                if (indexOf ?? -1 >= 0) {
                                    selectedCalenderEventItem.remove(at: indexOf!)
                                }
                            }
                            // refresh
                            calenderEvents = getCalenderList()
                        }
                    }
                    .onDisappear {
                        NotificationCenter.default.removeObserver(self)
                    }
                }
            }
            Spacer()
        }.onAppear(){
            self.loadData()
        }
        .padding()
    }
    
    func loadData(){
        textArr.removeAll()
        for i in 0...count{
            textArr.append(String("\(i) Hello, world!"))
        }
    }
}

struct CalenderEventItemView: View {
    @Binding var eventItem: CalenderEventItem
    @State private var isChecked: Bool = false
    private let wordLength = 18

    var body: some View {
        HStack(spacing: 3) {
            Toggle(isOn: self.$isChecked) {
                Text("")
            }
            .toggleStyle(CheckboxStyle())
            .onTapGesture {
                self.isChecked.toggle()
                if (self.isChecked) {
                    selectedCalenderEventItem.append(eventItem.id)
                } else {
                    if (selectedCalenderEventItem.count > 0 && selectedCalenderEventItem.contains(eventItem.id)) {
                        let indexOf = selectedCalenderEventItem.firstIndex(of: eventItem.id)
                        if (indexOf ?? -1 >= 0) {
                            selectedCalenderEventItem.remove(at: indexOf!)
                        }
                    }
                }
                
                print("select event id \(eventItem.id)")
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(eventItem.title.count > wordLength ? eventItem.title.prefix(wordLength) + "..." : eventItem.title)
                    .padding(.bottom, 3)
                Text("起:\(dateFormatter.string(from: eventItem.startDate)) - 终:\(dateFormatter.string(from: eventItem.endDate))")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}

/**
 时间格式转换器
 */
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
}()

/**
 获取自定义日历事件数据

 - Returns:
 */
func getCalenderList() -> [CalenderEventItem] {
    // 授权访问
    let eventStore = EKEventStore()
    let events = getCalendarEvents(eventStore: EKEventStore(), dayRanges: -365)
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

struct CheckboxStyle: ToggleStyle {
    let checkIcon   = "square"
    let checkedIcon = "checkmark.square.fill"
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
