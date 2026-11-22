//
//  ContentView.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 31.10.26.
//

import SwiftUI
import TipKit
import SwiftData

struct ContentView: View {
  @AppStorage("showOnboarding") private var showOnboarding = true
  @Environment(\.modelContext) private var modelContext
  @Environment(\.scenePhase) private var scenePhase
  @Query(sort: \Animal.createdAt) private var animals: [Animal]
  @State private var isAddingAnimal = false
  @State private var shouldAskForReminders = false 
  @State private var reminderRefresh = 0
  @State private var reminderError: String?
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
                  _ = try await Reminders.requestPermission()
                  shouldAskForReminders = false
                  reminderRefresh += 1
                } catch {
                  reminderError = error.localizedDescription
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
              if !Task.isCancelled { reminderError = error.localizedDescription }
            }
          }
        }
        .alert("Could not set reminder", isPresented: Binding(
          get: { reminderError != nil },
          set: { if !$0 { reminderError = nil } }
        )) {
          Button("OK", role: .cancel) { reminderError = nil }
        } message: {
          Text(reminderError ?? "")
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

#Preview {
    ContentView()
      .modelContainer(for: Animal.self, inMemory: true)
}
