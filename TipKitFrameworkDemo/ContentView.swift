//
//  ContentView.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 31.10.26.
//

import SwiftUI
import TipKit

struct ContentView: View {
  @State private var animals: [Animal] = []
  @State private var isAddingAnimal = false
  private let addAnimalTip = AddAnimalTip()
  
    var body: some View {
      NavigationStack {
        List {
          TipView(addAnimalTip)
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
            AddAnimalTip.invalidate(reason: .actionPerformed)
          }
        }
      }
    }
}

#Preview {
    ContentView()
}
