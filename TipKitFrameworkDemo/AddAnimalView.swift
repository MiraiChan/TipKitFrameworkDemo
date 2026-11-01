//
//  AddAnimalView.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 01.11.26.
//

import SwiftUI

struct AddAnimalView: View {
  let onSave: (Animal) -> Void
  @Environment(\.dismiss) private var dismiss
  @State private var name = ""
  @State private var days = 7
  
  var body: some View {
    NavigationStack {
      Form {
        TextField("Animal name", text: $name)
          .autocorrectionDisabled()
      }
      .navigationTitle("New Animal")
      .toolbar {
        Button("Save") {
          onSave(Animal(name: name, daysBnChangingTheLitter: days))
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
