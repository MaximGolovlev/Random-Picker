//
//  MainTabView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//


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
                    Text("Lists")
                }
                .tag(0)
            
            HistoryView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .tag(1)
        }
        .accentColor(.cyan)
        .preferredColorScheme(.dark)
    }
}