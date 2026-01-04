//
//  LinkedCategoryModal.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/2/26.
//

import Foundation


struct LinkedExercise {
    var id: String?
    var exerciseName: String?
    var originCategory: String?
    var categories: [LinkedInfo]
}

struct LinkedInfo {
    var category: String
    var location: Int
    var hidden: Bool
}

