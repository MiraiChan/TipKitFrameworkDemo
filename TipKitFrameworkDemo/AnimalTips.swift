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
    Image(systemName: "animal")
  }
}
