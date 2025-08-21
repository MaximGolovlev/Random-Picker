//
//  EmptyListView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//

import SwiftUI

struct EmptyListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet")
                .font(.system(size: 60))
                .foregroundColor(.cyan.opacity(0.5))
            
            Text("Create your first list")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text("For example: Restaurants, Movies, Vacation spots")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
