//
//  HistoryRowView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//

import SwiftUI

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
