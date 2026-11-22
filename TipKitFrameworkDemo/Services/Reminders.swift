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
  
  static func requestPermission() async throws -> Bool {
    try await UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound])
  }
  
  static func schedule(id: UUID, name: String, on date: Date) async throws {
    let identifier = id.uuidString
    var day = Calendar.current.dateComponents([.year, .month, .day], from: date)
    day.hour = 9
    guard let reminderDate = Calendar.current.date(from: day), reminderDate > .now else {
      cancel(id: id)
      return
    }

    let content = UNMutableNotificationContent()
    content.title = "Time to change \(name)'s litter"
    content.sound = .default
    let trigger = UNCalendarNotificationTrigger(dateMatching: day, repeats: false)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    try await UNUserNotificationCenter.current().add(request)
  }

  static func cancel(id: UUID) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
  }
}
