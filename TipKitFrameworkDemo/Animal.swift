//
//  Animal.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 31.10.26.
//

import Foundation

struct Animal: Identifiable {
  let id = UUID()
  let name: String
  let daysBnChangingTheLitter: Int
  
  var nextChanging: Date {
    Calendar.current.date(byAdding: .day, value: daysBnChangingTheLitter, to: .now)!
  }
}
