//
//  Animal.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 31.10.26.
//

import Foundation
import SwiftData

@Model
final class Animal {
  var id: UUID
  var name: String
  var daysBnChangingTheLitter: Int
  var createdAt: Date
  var nextChanging: Date

  init(name: String, daysBnChangingTheLitter: Int, createdAt: Date = .now) {
    self.id = UUID()
    self.name = name
    self.daysBnChangingTheLitter = daysBnChangingTheLitter
    self.createdAt = createdAt
    self.nextChanging = Calendar.current.date(
      byAdding: .day,
      value: daysBnChangingTheLitter,
      to: createdAt
    ) ?? createdAt
  }

  func markLitterChanged(on date: Date = .now) {
    nextChanging = Calendar.current.date(
      byAdding: .day,
      value: daysBnChangingTheLitter,
      to: date
    ) ?? date
  }
}
