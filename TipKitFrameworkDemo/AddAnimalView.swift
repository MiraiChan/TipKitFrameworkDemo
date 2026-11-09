//
//  AddAnimalView.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 01.11.26.
//

import SwiftUI
import TipKit

struct AddAnimalView: View {
  let onSave: (Animal) -> Void
  @Environment(\.dismiss) private var dismiss
  @State private var name = ""
  @State private var days = 7
  private var litterTip = LitterTip()
  
  var body: some View {
    NavigationStack {
      Form {
        TextField("Animal name", text: $name)
          .autocorrectionDisabled()
        Stepper("Change litter every \(days) days", value: $days, in: 1...30)
          .popoverTip(litterTip)
          .onChange(of: days) {
            litterTip.invalidate(reason: .actionPerformed)
          }
      }
      .navigationTitle("New Animal")
      .toolbar {
        Button("Save") {
          onSave(Animal(name: name, daysBnChangingTheLitter: days))
          Task {
            await LitterTip.animalAdded.donate()
          }
          dismiss()
        }
        .disabled(name.isEmpty)
      }
    }
  }
}

#Preview {
  AddAnimalView { _ in }
}
