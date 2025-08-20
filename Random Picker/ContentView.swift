//
//  ContentView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 20.08.2025.
//

// DecisionList.swift
import Foundation

struct DecisionList: Identifiable, Codable {
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

// DataManager.swift
import Foundation

class DataManager: ObservableObject {
    @Published var lists: [DecisionList] = []
    private let listsKey = "decisionLists"
    
    init() {
        loadLists()
    }
    
    func saveLists() {
        if let encoded = try? JSONEncoder().encode(lists) {
            UserDefaults.standard.set(encoded, forKey: listsKey)
        }
    }
    
    func loadLists() {
        if let data = UserDefaults.standard.data(forKey: listsKey),
           let decoded = try? JSONDecoder().decode([DecisionList].self, from: data) {
            lists = decoded
        }
    }
    
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

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var showingAddList = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.lists) { list in
                    NavigationLink(destination: ListDetailView(list: list, dataManager: dataManager)) {
                        VStack(alignment: .leading) {
                            Text(list.title)
                                .font(.headline)
                            Text("\(list.items.count) вариантов")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: dataManager.deleteList)
            }
            .navigationTitle("Списки решений")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddList = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddList) {
                AddListView(dataManager: dataManager)
            }
            .overlay {
                if dataManager.lists.isEmpty {
                    VStack {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Создайте свой первый список")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
        }
    }
}

// AddListView.swift
import SwiftUI

struct AddListView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager: DataManager
    @State private var title = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Название списка")) {
                    TextField("Например: Рестораны", text: $title)
                }
            }
            .navigationTitle("Новый список")
            .navigationBarItems(
                leading: Button("Отмена") { dismiss() },
                trailing: Button("Сохранить") {
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


// ListDetailView.swift
import SwiftUI

struct ListDetailView: View {
    let list: DecisionList
    @ObservedObject var dataManager: DataManager
    @State private var showingAddItem = false
    @State private var selectedItem: String?
    @State private var isSpinning = false
    
    var body: some View {
        VStack {
            // Кнопка выбора случайного варианта
            if !list.items.isEmpty {
                VStack {
                    Button(action: startRandomSelection) {
                        VStack {
                            Image(systemName: "dice")
                                .font(.system(size: 40))
                                .rotationEffect(.degrees(isSpinning ? 360 : 0))
                                .animation(isSpinning ? Animation.linear(duration: 0.5).repeatCount(5, autoreverses: false) : .default, value: isSpinning)
                            
                            Text("Выбрать случайно")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .padding()
                    
                    if let selectedItem = selectedItem {
                        Text("Выбран: \(selectedItem)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .transition(.scale)
                    }
                }
            }
            
            // Список элементов
            List {
                ForEach(Array(list.items.enumerated()), id: \.element) { index, item in
                    Text(item)
                }
                .onDelete { indexSet in
                    dataManager.deleteItem(from: list.id, at: indexSet)
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle(list.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(list: list, dataManager: dataManager)
        }
    }
    
    private func startRandomSelection() {
        guard !list.items.isEmpty else { return }
        
        isSpinning = true
        selectedItem = nil
        
        // Анимация выбора с задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isSpinning = false
            selectedItem = list.items.randomElement()
        }
    }
}

// AddItemView.swift
import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    let list: DecisionList
    @ObservedObject var dataManager: DataManager
    @State private var newItem = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Новый вариант")) {
                    TextField("Введите вариант", text: $newItem)
                }
                
                Section(header: Text("Существующие варианты")) {
                    ForEach(list.items, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            .navigationTitle("Добавить в \(list.title)")
            .navigationBarItems(
                leading: Button("Отмена") { dismiss() },
                trailing: Button("Добавить") {
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
