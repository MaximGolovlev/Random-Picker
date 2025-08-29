//
//  HistoryView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//

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
                    VStack(spacing: 20) {
                        header
                            .padding(.top, 40)
                        Spacer()
                        EmptyHistoryView()
                        Spacer()
                    }
                } else {
                    VStack(spacing: 20) {
                        header
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
            }
            //   .navigationTitle("Selection History")
            //   .navigationBarTitleDisplayMode(.large)
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
            .alert("Clear History?", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    dataManager.clearHistory()
                }
            }
        }
    }
    
    var header: some View {
        VStack(spacing: 12) {
            Text("Selection History")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Track all your random choices and decisions over time")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
