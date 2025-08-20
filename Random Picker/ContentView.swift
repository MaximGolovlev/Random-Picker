//
//  ContentView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 20.08.2025.
//

// Models/GenerationHistory.swift
import Foundation

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

// Managers/DataManager.swift
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

// Views/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedTab = 0
    
    init() {
        // Настраиваем неоновый внешний вид TabBar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(.black)
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(.cyan)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(.cyan)]
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(.gray)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(.gray)]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ListsView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Списки")
                }
                .tag(0)
            
            HistoryView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("История")
                }
                .tag(1)
        }
        .accentColor(.cyan)
        .preferredColorScheme(.dark)
    }
}

// Views/ListsView.swift
import SwiftUI

struct ListsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddList = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Неоновый градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.1, green: 0, blue: 0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if dataManager.lists.isEmpty {
                    EmptyListView()
                } else {
                    List {
                        ForEach(dataManager.lists) { list in
                            NavigationLink(destination: ListDetailView(list: list, dataManager: dataManager)) {
                                ListRowView(list: list)
                            }
                            .listRowBackground(Color.black.opacity(0.3))
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .onDelete(perform: deleteList)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Списки решений")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddList = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.cyan)
                    }
                }
            }
            .sheet(isPresented: $showingAddList) {
                AddListView(dataManager: dataManager)
            }
        }
    }
    
    private func deleteList(at indexSet: IndexSet) {
        dataManager.deleteList(at: indexSet)
    }
}

struct ListRowView: View {
    let list: DecisionList
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(list.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(list.items.count) вариантов")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.cyan.opacity(0.7))
                .font(.system(size: 14, weight: .bold))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.1, blue: 0.3),
                        Color(red: 0.1, green: 0, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [.cyan.opacity(0.3), .purple.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
        )
    }
}

struct EmptyListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet")
                .font(.system(size: 60))
                .foregroundColor(.cyan.opacity(0.5))
            
            Text("Создайте свой первый список")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text("Например: Рестораны, Фильмы, Места для отдыха")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// Views/HistoryView.swift
import SwiftUI

struct HistoryView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Неоновый градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.1, green: 0, blue: 0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if dataManager.generationHistory.isEmpty {
                    EmptyHistoryView()
                } else {
                    List {
                        ForEach(dataManager.generationHistory) { history in
                            HistoryRowView(history: history)
                        }
                        .listRowBackground(Color.black.opacity(0.3))
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("История выборов")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !dataManager.generationHistory.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingClearAlert = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("Очистить историю?", isPresented: $showingClearAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Очистить", role: .destructive) {
                    dataManager.clearHistory()
                }
            }
        }
    }
}

struct HistoryRowView: View {
    let history: GenerationHistory
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(history.selectedItem)
                    .font(.headline)
                    .foregroundColor(.cyan)
                
                Text(history.listTitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(history.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "dice")
                .foregroundColor(.purple)
                .font(.system(size: 20))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.1, blue: 0.3),
                        Color(red: 0.1, green: 0, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [
                                .purple.opacity(0.3),
                                .cyan.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
        )
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.purple.opacity(0.5))
            
            Text("История выборов пуста")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text("Сделайте несколько случайных выборов в списках, и они появятся здесь")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// Views/ListDetailView.swift
import SwiftUI

struct ListDetailView: View {
    let list: DecisionList
    @ObservedObject var dataManager: DataManager
    @State private var showingAddItem = false
    @State private var selectedItem: String?
    @State private var isSpinning = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Неоновый градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.1, green: 0, blue: 0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Кнопка выбора случайного варианта
                if !list.items.isEmpty {
                    VStack(spacing: 20) {
                        Button(action: startRandomSelection) {
                            ZStack {
                                // Неоновое свечение
                                Circle()
                                    .fill(
                                        AngularGradient(
                                            gradient: Gradient(colors: [
                                                .cyan,
                                                .purple,
                                                .cyan
                                            ]),
                                            center: .center,
                                            startAngle: .degrees(0),
                                            endAngle: .degrees(360)
                                        )
                                    )
                                    .blur(radius: 10)
                                    .opacity(0.3)
                                
                                Circle()
                                    .fill(Color.black)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.cyan, .purple]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                    )
                                
                                VStack(spacing: 8) {
                                    Image(systemName: "dice")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.cyan)
                                        .rotationEffect(.degrees(rotationAngle))
                                    
                                    Text("Выбрать случайно")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: 150, height: 150)
                        }
                        
                        if let selectedItem = selectedItem {
                            VStack {
                                Text("Выбран:")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text(selectedItem)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.cyan)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.black.opacity(0.5))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                }
                
                // Список элементов
                List {
                    ForEach(Array(list.items.enumerated()), id: \.element) { index, item in
                        Text(item)
                            .foregroundColor(.white)
                    }
                    .onDelete { indexSet in
                        dataManager.deleteItem(from: list.id, at: indexSet)
                    }
                    .listRowBackground(Color.black.opacity(0.3))
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(list.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(.cyan)
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
        
        // Анимация вращения
        withAnimation(.linear(duration: 0.1).repeatCount(20, autoreverses: false)) {
            rotationAngle += 360 * 5
        }
        
        // Задержка перед выбором
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isSpinning = false
            if let randomItem = list.items.randomElement() {
                selectedItem = randomItem
                dataManager.addToHistory(listTitle: list.title, selectedItem: randomItem)
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
