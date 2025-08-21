//
//  DataManager.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//

import Combine
import Foundation

class DataManager: ObservableObject {
    @Published var lists: [DecisionList] = []
    @Published var generationHistory: [GenerationHistory] = []
    
    private let listsKey = "decisionLists"
    private let historyKey = "generationHistory"
    
    init() {
        loadLists()
        loadHistory()
    }
    
    // Методы для списков...
    func saveLists() {
        if let encoded = try? JSONEncoder().encode(lists) {
            UserDefaults.standard.set(encoded, forKey: listsKey)
        }
        loadLists()
    }
    
    func loadLists() {
        if let data = UserDefaults.standard.data(forKey: listsKey),
           let decoded = try? JSONDecoder().decode([DecisionList].self, from: data) {
            lists = decoded
        }
    }
    
    // Методы для истории
    func saveHistory() {
        if let encoded = try? JSONEncoder().encode(generationHistory) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
        loadHistory()
    }
    
    func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([GenerationHistory].self, from: data) {
            generationHistory = decoded.sorted { $0.timestamp > $1.timestamp }
        }
    }
    
    func addToHistory(listTitle: String, selectedItem: String) {
        let historyItem = GenerationHistory(listTitle: listTitle, selectedItem: selectedItem)
        generationHistory.insert(historyItem, at: 0)
        saveHistory()
    }
    
    func clearHistory() {
        generationHistory.removeAll()
        saveHistory()
    }
    
    // Остальные методы остаются без изменений...
    func addList(_ list: DecisionList) {
        lists.append(list)
        saveLists()
    }
    
    func updateList(_ list: DecisionList) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index] = list
            saveLists()
        }
    }
    
    func deleteList(at indexSet: IndexSet) {
        lists.remove(atOffsets: indexSet)
        saveLists()
    }
    
    func addItem(to listId: UUID, item: String) {
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            lists[index].items.append(item)
            saveLists()
        }
    }
    
    func deleteItem(from listId: UUID, at indexSet: IndexSet) {
        if let listIndex = lists.firstIndex(where: { $0.id == listId }) {
            lists[listIndex].items.remove(atOffsets: indexSet)
            saveLists()
        }
    }
}
