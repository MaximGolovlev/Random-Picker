//
//  AddListView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//


import SwiftUI

struct AddListView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager: DataManager
    @State private var title = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("List Name")) {
                    TextField("e.g., Restaurants", text: $title)
                }
            }
            .navigationTitle("New List")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    if !title.isEmpty {
                        let newList = DecisionList(title: title)
                        dataManager.addList(newList)
                        dismiss()
                    }
                }
                    .disabled(title.isEmpty)
            )
        }
    }
}