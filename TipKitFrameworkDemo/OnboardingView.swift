//
//  OnboardingView.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 17.11.26.
//

import SwiftUI

struct OnboardingView: View {
  let onFinish: (Animal?) -> Void
  @State private var page = 0
  @State private var isAddingAnimal = false
  
  private let pages = [
    (symbol: "paw", title: "Never guess when to change the litter", detail: "Litty knows which animal toilet needs to be refreshed, and when."),
    (symbol: "calendar", title: "Every animal, its own schedule", detail: "A kind reminder will help."),
    (symbol: "dog", title: "Start with one animal", detail: "It takes not much time."),
  ]
  
  var body: some View {
    VStack(spacing: 24) {
      TabView(selection: $page) {
        ForEach(pages.indices, id:\.self) { index in
          VStack(spacing: 16) {
            Image(systemName: pages[index].symbol)
              .font(.system(size: 72))
              .foregroundStyle(.green)
              .accessibilityHidden(true)
            Text(pages[index].title)
              .font(.largeTitle.bold())
              .multilineTextAlignment(.center)
            Text(pages[index].detail)
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
          }
          .padding(32)
          .tag(index)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      
      HStack(spacing: 8) {
        
      }
    }
  }
}
