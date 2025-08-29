//
//  AddItemView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//


import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    let list: DecisionList
    @ObservedObject var dataManager: DataManager
    @State private var newItem = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Option")) {
                    TextField("Enter option", text: $newItem)
                }
                
                Section(header: Text("Existing Options")) {
                    ForEach(list.items, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            .navigationTitle("Add to \(list.title)")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    if !newItem.isEmpty {
                        dataManager.addItem(to: list.id, item: newItem)
                        dismiss()
                    }
                }
                    .disabled(newItem.isEmpty)
            )
        }
    }
}