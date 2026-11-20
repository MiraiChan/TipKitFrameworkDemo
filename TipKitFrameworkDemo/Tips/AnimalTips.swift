//
//  AnimalTips.swift
//  TipKitFrameworkDemo
//
//  Created by Almira Khafizova on 03.11.26.
//

import TipKit

struct AddAnimalTip: Tip {
  var title: Text {
    Text("Add your first animal")
  }
  
  var message: Text? {
    Text("Read when to change the litter")
  }
  
  var image: Image? {
    Image(systemName: "pawprint")
  }
}

struct DeleteTip: Tip {
  @Parameter(.transient)
  static var hasAnimal: Bool = false
  
  var title: Text {
    Text("Swipe to remove")
  }
  
  var message: Text? {
    Text("Swipe an animal to the left to take it off your list")
  }
  
  var rules: [Rule] {
    #Rule(Self.$hasAnimal) { $0 == true }
  }
}

struct LitterTip: Tip {
  static let animalAdded = Event(id: "animalAdded")
  
  var title: Text {
    Text("Not every animal's toilet needs to be changed once a week")
  }
  
  var message: Text? {
    Text("Set how many days this one can go between changing the toilet litter.")
  }
  
  var image: Image? {
    Image(systemName: "toilet")
  }
  
  var rules: [Rule] {
    #Rule(Self.animalAdded) { $0.donations.count >= 1 }
  }
}
