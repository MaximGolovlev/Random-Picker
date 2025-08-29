//
//  ListDetailView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//


import SwiftUI

struct ListDetailView: View {
    @Binding var list: DecisionList
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
                                RoundedRectangle(cornerRadius: 16)
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
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
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
                                    
                                    Text("Choose Random")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: 180, height: 150)
                        }
                        
                        if let selectedItem = selectedItem {
                            VStack {
                                Text("Selected:")
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