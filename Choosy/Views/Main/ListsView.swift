//
//  ListsView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//


import SwiftUI

struct ListsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddList = false
    @State private var paths = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $paths) {
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
                    VStack(spacing: 20) {
                        header
                        Spacer()
                        EmptyListView()
                        Spacer()
                    }
                } else {
                    VStack(spacing: 20) {
                        header
                        List {
                            ForEach(dataManager.lists) { list in
                                Button(action: {
                                    paths.append(list)
                                }) {
                                    ListRowView(list: list)
                                }
                                .listRowBackground(Color.black.opacity(0.3))
                            }
                            .onDelete(perform: deleteList)
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                    }
                }
            }
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
            .navigationDestination(for: DecisionList.self) { list in
                if let index = dataManager.lists.firstIndex(where: { $0.id == list.id }) {
                    ListDetailView(list: $dataManager.lists[index], dataManager: dataManager)
                }
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Text("Decision Maker")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("The perfect tool for making quick decisions when you can't choose")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private func deleteList(at indexSet: IndexSet) {
        dataManager.deleteList(at: indexSet)
    }
}
