//
//  ListRowView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//

import SwiftUI

struct ListRowView: View {
    let list: DecisionList
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(list.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(list.items.count) options")
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
