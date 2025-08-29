//
//  DecisionList.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//


import Foundation

struct DecisionList: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var items: [String]
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, items: [String] = [], createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.items = items
        self.createdAt = createdAt
    }
}