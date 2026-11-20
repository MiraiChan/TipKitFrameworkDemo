//
//  TipKitFrameworkDemoApp.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 31.10.26.
//

import SwiftUI
import TipKit

@main
struct TipKitFrameworkDemoApp: App {
  init() {
    try? Tips.configure([
      .displayFrequency(.immediate)
    ])
  }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
