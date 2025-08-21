//
//  EmptyHistoryView.swift
//  Random Picker
//
//  Created by Maxim Golovlev on 21.08.2025.
//

import SwiftUI

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.purple.opacity(0.5))
            
            Text("No selection history")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text("Make some random selections in your lists and they will appear here")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
