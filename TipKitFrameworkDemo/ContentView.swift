//
//  ContentView.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 31.10.26.
//

import SwiftUI
import TipKit

struct ContentView: View {
  @AppStorage("showOnboarding") private var showOnboarding = true
  @State private var animals: [Animal] = []
  @State private var isAddingAnimal = false
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
          }
          .onDelete { offsets in
            animals.remove(atOffsets: offsets)
            deleteTip.invalidate(reason: .actionPerformed)
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
            animals.append(animal)
            addAnimalTip.invalidate(reason: .actionPerformed)
          }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
          OnboardingView { animal in
            if let animal {
              animals.append(animal)
            }
            showOnboarding = false
          }
        }
        .onChange(of: animals.isEmpty) {
          DeleteTip.hasAnimal = !animals.isEmpty
        }
      }
    }
}

#Preview {
    ContentView()
}
