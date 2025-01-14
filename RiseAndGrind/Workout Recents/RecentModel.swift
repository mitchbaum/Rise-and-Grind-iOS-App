//
//  RecentModel.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/6/25.
//

import Foundation

struct Recent {
    var date: String?
    var categories: [RecentCategory]
    
}
struct RecentCategory {
    var id: String?
    var category: String?
    var timestamp: String?
    var date: String?
}



