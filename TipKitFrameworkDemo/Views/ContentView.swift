//
//  ContentView.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 31.10.26.
//

import SwiftUI
import TipKit
import SwiftData
import UIKit

struct ContentView: View {
  @AppStorage("showOnboarding") private var showOnboarding = true
  @Environment(\.modelContext) private var modelContext
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.openURL) private var openURL
  @Query(sort: \Animal.createdAt) private var animals: [Animal]
  @State private var isAddingAnimal = false
  @State private var shouldAskForReminders = false 
  @State private var reminderRefresh = 0
  @State private var reminderError: ReminderError?
  private let addAnimalTip = AddAnimalTip()
  private let deleteTip = DeleteTip()
  
    var body: some View {
      NavigationStack {
        List {
          TipView(addAnimalTip)
          TipView(deleteTip)
          ForEach(animals) { animal in
            VStack(alignment: .leading) {
              Text(animal.name)
                .font(.headline)
              Text("Change the litter on \(animal.nextChanging, format: .dateTime.weekday(.wide).month().day())")
                .foregroundStyle(.secondary)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
              Button("Litter changed", systemImage: "checkmark") {
                animal.markLitterChanged()
              }
              .tint(.green)
              Button("Delete", systemImage: "trash", role: .destructive) {
                deleteAnimal(animal)
              }
            }
          }
          .onDelete { offsets in
              for index in offsets {
                deleteAnimal(animals[index])
              }
          }
          if shouldAskForReminders, let animal = animals.first {
            ReminderPrimer(animal: animal) {
              Task {
                do {
                  let granted = try await Reminders.requestPermission()
                  shouldAskForReminders = false
                  reminderRefresh += 1
                  if !granted {
                    reminderError = .permissionDenied
                  }
                } catch {
                  reminderError = .permissionRequest
                }
              }
            } onDismiss: {
              shouldAskForReminders = false
            }
          }
        }
        .overlay {
          if animals.isEmpty {
            ContentUnavailableView {
              Label("No animals yet", systemImage: "pawprint.fill")
            } description: {
              Text("Add the fresh litter. Litty will tell you when it is needed.")
            } actions: {
              Button("Add your first animal") {
                isAddingAnimal = true
              }
              .buttonStyle(.borderedProminent)
            }
          }
        }
        .navigationTitle("Pets")
        .toolbar {
          Button("Add animal", systemImage: "plus") {
            isAddingAnimal = true
          }
        }
        .sheet(isPresented: $isAddingAnimal) {
          AddAnimalView { animal in
            modelContext.insert(animal)
            addAnimalTip.invalidate(reason: .actionPerformed)
          }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
          OnboardingView { animal in
            if let animal {
              modelContext.insert(animal)
            }
            showOnboarding = false
          }
        }
        .task(id: reminderTaskID) {
          guard scenePhase == .active, !animals.isEmpty else { return }
          let status = await Reminders.status()
          guard !Task.isCancelled else { return }
          shouldAskForReminders = status == .notDetermined
          guard status == .authorized || status == .provisional || status == .ephemeral else { return }

          for animal in animals {
            guard !Task.isCancelled else { return }
            let id = animal.id
            do {
              try await Reminders.schedule(id: id, name: animal.name, on: animal.nextChanging)
              if !animals.contains(where: { $0.id == id }) {
                Reminders.cancel(id: id)
              }
            } catch {
              if !Task.isCancelled { reminderError = .scheduling(animal.name) }
              return
            }
          }
        }
        .alert(item: $reminderError) { error in
          switch error {
          case .permissionDenied:
            Alert(
              title: Text("Notifications are off"),
              message: Text("Allow notifications in Settings to receive litter reminders."),
              primaryButton: .default(Text("Open Settings")) {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
              },
              secondaryButton: .cancel()
            )
          case .permissionRequest:
            Alert(
              title: Text("Could not request notification permission"),
              message: Text("Please try again."),
              dismissButton: .default(Text("OK"))
            )
          case .scheduling(let name):
            Alert(
              title: Text("Could not set reminder"),
              message: Text("The reminder for \(name) could not be scheduled. Please try again."),
              primaryButton: .default(Text("Retry")) { reminderRefresh += 1 },
              secondaryButton: .cancel()
            )
          }
        }
        .onChange(of: animals.isEmpty) {
          DeleteTip.hasAnimal = !animals.isEmpty
        }
      }
    }

  private var reminderTaskID: String {
    animals.map { "\($0.id.uuidString):\($0.nextChanging.timeIntervalSinceReferenceDate)" }
      .joined(separator: ",") + ":\(reminderRefresh):\(scenePhase)"
  }

  private func deleteAnimal(_ animal: Animal) {
    Reminders.cancel(id: animal.id)
    modelContext.delete(animal)
    deleteTip.invalidate(reason: .actionPerformed)
  }
}

private enum ReminderError: Identifiable {
  case permissionDenied
  case permissionRequest
  case scheduling(String)

  var id: String {
    switch self {
    case .permissionDenied: "permissionDenied"
    case .permissionRequest: "permissionRequest"
    case .scheduling(let name): "scheduling-\(name)"
    }
  }
}

#Preview {
    ContentView()
      .modelContainer(for: Animal.self, inMemory: true)
}
