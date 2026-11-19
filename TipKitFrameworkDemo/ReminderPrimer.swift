//
//  ReminderPrimer.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 19.11.26.
//

import SwiftUI

struct ReminderPrimer: View {
  let animal: Animal
  let onDone: () -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label(
        "Want a nudge when \(animal.name)'s litter needs to be changed?",
        systemImage: "bell.badge"
      )
      .font(.headline)
      
      Text("One notification on \(animal.nextChanging, format: .dateTime.weekday(.wide)). Nothing else.")
        .foregroundStyle(.secondary)
      
      HStack {
        Button("Remind me") {
          Task {
            // Request permission to send notifications.
            if await Reminders.requestPermission() {
              // Schedule a reminder for the next litter change.
              await Reminders.schedule(
                "Time to change \(animal.name)'s litter",
                on: animal.nextChanging
              )
              
              // Log pending notifications for debugging.
              await Reminders.logPending()
            }
            
            // Complete the reminder prompt.
            onDone()
          }
        }
        .buttonStyle(.borderedProminent)
        
        Button("Not now", action: onDone)
      }
    }
    .padding(.vertical, 8)
  }
}
