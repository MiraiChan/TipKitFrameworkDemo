//
//  Reminders.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 19.11.26.
//

import UserNotifications

enum Reminders {
  static func status() async -> UNAuthorizationStatus {
    await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
  }
  
  static func requestPermission() async -> Bool {
    let granted = try? await UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound])
    return granted ?? false
  }
  
  static func schedule(_ title: String, on date: Date) async {
    let content = UNMutableNotificationContent()
    content.title = title
    var day = Calendar.current.dateComponents([.year, .month, .day], from: date)
    day.hour = 9
    let trigger = UNCalendarNotificationTrigger(dateMatching: day, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    try? await UNUserNotificationCenter.current().add(request)
  }
  
  static func logPending() async {
    for request in await UNUserNotificationCenter.current().pendingNotificationRequests() {
      let trigger = request.trigger as? UNCalendarNotificationTrigger
      print(request.content.title, trigger?.nextTriggerDate()?.formatted() ?? "no date")
    }
  }
}
