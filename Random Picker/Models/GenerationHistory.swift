//
//  GenerationHistory.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//

import Foundation

struct GenerationHistory: Identifiable, Codable {
    let id: UUID
    let listTitle: String
    let selectedItem: String
    let timestamp: Date
    
    init(listTitle: String, selectedItem: String) {
        self.id = UUID()
        self.listTitle = listTitle
        self.selectedItem = selectedItem
        self.timestamp = Date()
    }
}
