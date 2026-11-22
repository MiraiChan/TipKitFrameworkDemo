//
//  ReminderPrimer.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 19.11.26.
//

import SwiftUI

struct ReminderPrimer: View {
  let animal: Animal
  let onEnable: () -> Void
  let onDismiss: () -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label(
        "Want a nudge when \(animal.name)'s litter needs to be changed?",
        systemImage: "bell.badge"
      )
      .font(.headline)
      
      Text("Get a notification when each animal's litter is due to be changed.")
        .foregroundStyle(.secondary)
      
      HStack {
        Button("Remind me") {
          onEnable()
        }
        .buttonStyle(.borderedProminent)
        
        Button("Not now", action: onDismiss)
      }
    }
    .padding(.vertical, 8)
  }
}
